import 'package:arrow_options/arrow_options.dart';
import 'package:logging/logging.dart';
import 'package:swisseph/swisseph.dart';

import 'asc_mc_points.dart';
import 'body_position.dart';
import 'cardinal_points.dart';
import 'eph_snapshot.dart';
import 'ephemeris_flag.dart';
import 'pheno_data.dart';
import 'sun_times.dart';

final _log = Logger('Arrow.Swe');

/// Facade over the Swiss Ephemeris library.
///
/// Wraps [SwissEph] to compute a complete [EphSnapshot] for a given time and
/// location. Each call to [calcAll] is stateless from the caller's perspective
/// — configuration is applied immediately before each calculation batch.
class SweFacade {
  final SwissEph _swe;
  final String? ephePath;
  final String? jplFile;

  /// Construct a facade over [swe].
  ///
  /// [ephePath] points at the directory containing Swiss Ephemeris data files
  /// (`.se1`, `sefstars.txt`, etc.). Required to use [EphemerisSource.swissEph]
  /// with real precision — SWE silently falls back to Moshier when unset.
  ///
  /// [jplFile] is the JPL ephemeris filename (e.g. `de431.eph`) resolved
  /// against [ephePath]. Required to use [EphemerisSource.jplEph].
  SweFacade(SwissEph swe, {this.ephePath, this.jplFile}) : _swe = swe {
    if (ephePath != null) {
      _log.info('setEphePath=$ephePath');
      _swe.setEphePath(ephePath!);
    }
    if (jplFile != null) {
      _log.info('setJplFile=$jplFile');
      _swe.setJplFile(jplFile!);
    }
  }

  /// Compute a complete ephemeris snapshot.
  EphSnapshot calcAll(double jdUt, Location location, ArrowOptions options) {
    final sweConfig = options.sweConfig;
    final loc = location;

    _log.info('calcAll jdUt=$jdUt bodies=${sweConfig.bodies.length} '
        'extraFrames=${sweConfig.extraFrames}');

    // Fail-fast: barycentric is not supported under Moshier.
    if (sweConfig.extraFrames.contains(ReferencePoint.barycentric) &&
        sweConfig.ephemerisSource == EphemerisSource.moshier) {
      throw ArgumentError(
        'barycentric positions unsupported under Moshier; '
        'use EphemerisSource.swissEph or .jplEph',
      );
    }

    // Configure sidereal mode if needed.
    final isSidereal = !sweConfig.signAyanamsa.isTropical;
    if (isSidereal && sweConfig.signAyanamsa.isStandard) {
      _swe.setSidMode(sweConfig.signAyanamsa.sweCode);
    }

    // Topocentric setup.
    if (sweConfig.topocentric) {
      _swe.setTopo(loc.longitude, loc.latitude, loc.altitude);
    }

    // Base flags.
    final baseEclFlags = ephemerisFlag(sweConfig.ephemerisSource) |
        seFlgSpeed |
        (isSidereal ? seFlgSidereal : 0) |
        (sweConfig.topocentric ? seFlgTopoCtr : 0);
    final equatorialFlags = baseEclFlags | seFlgEquatorial;

    // Extra-frame flags strip topocentric — it is Earth-surface–specific and
    // meaningless against the SSB / Sun origin.
    final extraBase = baseEclFlags & ~seFlgTopoCtr;

    final bodiesEcliptic = <Body, BodyPosition>{};
    final bodiesEquatorial = <Body, BodyPosition>{};
    final phenoData = <Body, PhenoData>{};

    final baryEcl = sweConfig.extraFrames.contains(ReferencePoint.barycentric)
        ? <Body, BodyPosition>{}
        : null;
    final helioEcl = sweConfig.extraFrames.contains(ReferencePoint.heliocentric)
        ? <Body, BodyPosition>{}
        : null;

    BodyPosition? rahuEcl;
    BodyPosition? rahuEqu;
    BodyPosition? rahuBaryEcl;
    BodyPosition? rahuHelioEcl;

    // Calculate each requested body (skip ketu — computed from rahu).
    for (final body in sweConfig.bodies) {
      if (body == Body.ketu) continue;

      final sweId = body == Body.rahu
          ? (sweConfig.trueNode ? seTrueNode : seMeanNode)
          : body.sweId;

      _log.fine('calc body=$body sweId=$sweId');

      final ecl = _swe.calcUt(jdUt, sweId, baseEclFlags);
      final equ = _swe.calcUt(jdUt, sweId, equatorialFlags);

      final eclPos = _fromCalcResult(ecl);
      final equPos = _fromCalcResult(equ);

      bodiesEcliptic[body] = eclPos;
      bodiesEquatorial[body] = equPos;

      final pheno = _safePheno(jdUt, body, sweId, baseEclFlags);
      if (pheno != null) phenoData[body] = pheno;

      if (body == Body.rahu) {
        rahuEcl = eclPos;
        rahuEqu = equPos;
      }

      if (baryEcl != null) {
        final r = _swe.calcUt(jdUt, sweId, extraBase | seFlgBaryCtr);
        final pos = _fromCalcResult(r);
        baryEcl[body] = pos;
        if (body == Body.rahu) rahuBaryEcl = pos;
      }
      if (helioEcl != null && body != Body.sun) {
        final r = _swe.calcUt(jdUt, sweId, extraBase | seFlgHelCtr);
        final pos = _fromCalcResult(r);
        helioEcl[body] = pos;
        if (body == Body.rahu) rahuHelioEcl = pos;
      }
    }

    // Compute Ketu from Rahu if both are requested.
    if (sweConfig.bodies.contains(Body.ketu) && rahuEcl != null && rahuEqu != null) {
      bodiesEcliptic[Body.ketu] = _ketuFrom(rahuEcl);
      bodiesEquatorial[Body.ketu] = _ketuFrom(rahuEqu);
      if (baryEcl != null && rahuBaryEcl != null) {
        baryEcl[Body.ketu] = _ketuFrom(rahuBaryEcl);
      }
      if (helioEcl != null && rahuHelioEcl != null) {
        helioEcl[Body.ketu] = _ketuFrom(rahuHelioEcl);
      }
    }

    // House cusps and ascmc.
    // housesEx takes hsys as the ASCII code of the house system character.
    final hsys = sweConfig.houseSystem.sweChar.codeUnitAt(0);
    final houseFlags = isSidereal ? seFlgSidereal : 0;
    final houseResult = _swe.housesEx(
      jdUt,
      houseFlags,
      loc.latitude,
      loc.longitude,
      hsys,
    );
    // cusps[0] is unused in SWE (1-based), so we take indices 1..12.
    final cusps = List<double>.generate(12, (i) => houseResult.cusps[i + 1]);
    final ascmc = _ascMcFromList(houseResult.ascmc);

    // Ayanamsa value.
    double ayanamsaValue = 0.0;
    if (isSidereal) {
      ayanamsaValue = _swe.getAyanamsaUt(jdUt);
      _log.fine('ayanamsa=$ayanamsaValue');
    }

    // Sunrise / sunset.
    final sunTimes = _calcSunTimes(jdUt, loc);

    return EphSnapshot(
      jdUt: jdUt,
      location: location,
      options: options,
      bodiesEcliptic: bodiesEcliptic,
      bodiesEquatorial: bodiesEquatorial,
      phenoData: phenoData,
      cusps: cusps,
      ascmc: ascmc,
      sunTimes: sunTimes,
      ayanamsaValue: ayanamsaValue,
      bodiesEclipticBarycentric: baryEcl,
      bodiesEclipticHeliocentric: helioEcl,
    );
  }

  BodyPosition _fromCalcResult(CalcResult r) => BodyPosition(
        longitude: r.longitude,
        latitude: r.latitude,
        distance: r.distance,
        speedLongitude: r.longitudeSpeed,
        speedLatitude: r.latitudeSpeed,
        speedDistance: r.distanceSpeed,
      );

  /// Call `swe_pheno_ut` for [body]. Skips lunar nodes (mathematical points
  /// with no pheno output); logs and returns null on SWE error. Flags use
  /// the base ecliptic flags minus `seFlgSidereal`/`seFlgEquatorial`
  /// (pheno is a geocentric angular quantity; sidereal frame is irrelevant).
  PhenoData? _safePheno(double jdUt, Body body, int sweId, int flags) {
    if (body == Body.rahu || body == Body.ketu) return null;
    final phenoFlags = flags & ~(seFlgSidereal | seFlgEquatorial);
    try {
      final r = _swe.phenoUt(jdUt, sweId, phenoFlags);
      return PhenoData(
        phaseAngle: r.phaseAngle,
        phase: r.phase,
        elongation: r.elongation,
        apparentDiameter: r.apparentDiameter,
        apparentMagnitude: r.apparentMagnitude,
      );
    } catch (e) {
      _log.warning('pheno calc failed for $body: $e');
      return null;
    }
  }

  BodyPosition _ketuFrom(BodyPosition rahu) => BodyPosition(
        longitude: (rahu.longitude + 180.0) % 360.0,
        latitude: -rahu.latitude,
        distance: rahu.distance,
        speedLongitude: rahu.speedLongitude,
        speedLatitude: -rahu.speedLatitude,
        speedDistance: rahu.speedDistance,
      );

  AscMcPoints _ascMcFromList(List<double> a) => AscMcPoints(
        ascendant: a[0],
        mc: a[1],
        armc: a[2],
        vertex: a[3],
        equatorialAscendant: a[4],
        coAscendantKoch: a[5],
        coAscendantMunkasey: a[6],
        polarAscendant: a[7],
      );

  SunTimes _calcSunTimes(double jdUt, Location loc) {
    double? sunrise;
    double? sunset;

    try {
      final r = _swe.riseTrans(
        jdUt,
        seSun,
        rsmi: seCalcRise,
        geolon: loc.longitude,
        geolat: loc.latitude,
        geoalt: loc.altitude,
      );
      sunrise = r.transitTime;
    } catch (e) {
      _log.warning('sunrise calc failed: $e');
    }

    try {
      final r = _swe.riseTrans(
        jdUt,
        seSun,
        rsmi: seCalcSet,
        geolon: loc.longitude,
        geolat: loc.latitude,
        geoalt: loc.altitude,
      );
      sunset = r.transitTime;
    } catch (e) {
      _log.warning('sunset calc failed: $e');
    }

    return SunTimes(sunrise: sunrise, sunset: sunset);
  }

  /// Ayanamsa value (arc-degrees) for ephemeris time [jdEt] under [ayanamsa].
  ///
  /// Returns 0.0 for tropical. For non-tropical standard ayanamsas, applies
  /// `setSidMode` before delegating to `swe_get_ayanamsa` (ET variant).
  ///
  /// The UT variant is computed internally by [calcAll] and stored on the
  /// resulting [EphSnapshot] as `ayanamsaValue`; use this method when you
  /// need ET input or ad-hoc computation outside a full snapshot.
  ///
  /// Non-standard ayanamsas (custom `setSidModeEx` configurations) are not
  /// supported here; pass a standard [Ayanamsa].
  double getAyanamsa(double jdEt, Ayanamsa ayanamsa) =>
      _ayanamsaWith(ayanamsa, () => _swe.getAyanamsa(jdEt));

  /// Ayanamsa value (arc-degrees) for universal time [jdUt] under [ayanamsa].
  ///
  /// UT counterpart of [getAyanamsa]. Differs by roughly delta-T (~64s worth
  /// of precession ≈ 0.001°) — negligible for sign-level work, meaningful
  /// for sub-arcsecond calculations.
  double getAyanamsaUt(double jdUt, Ayanamsa ayanamsa) =>
      _ayanamsaWith(ayanamsa, () => _swe.getAyanamsaUt(jdUt));

  double _ayanamsaWith(Ayanamsa ayanamsa, double Function() compute) {
    if (ayanamsa.isTropical) return 0.0;
    if (ayanamsa.isStandard) {
      _swe.setSidMode(ayanamsa.sweCode);
    }
    return compute();
  }

  /// Find the four tropical cardinal points of calendar [year]: the JDs (UT)
  /// at which the Sun reaches tropical longitudes 0°, 90°, 180°, 270°.
  ///
  /// [source] selects the underlying ephemeris — defaults to Swiss Ephemeris.
  /// Sidereal and topocentric settings from [ArrowOptions] are irrelevant:
  /// equinoxes and solstices are defined against the tropical frame.
  CardinalPoints calcCardinalPoints(
    int year, {
    EphemerisSource source = EphemerisSource.swissEph,
  }) {
    final jdStart = _swe.julday(year, 1, 1, 0.0);
    final flags = ephemerisFlag(source);
    _log.info('calcCardinalPoints year=$year jdStart=$jdStart');
    return CardinalPoints(
      ascendingEquinox: _swe.solCrossUt(0.0, jdStart, flags),
      northernSolstice: _swe.solCrossUt(90.0, jdStart, flags),
      descendingEquinox: _swe.solCrossUt(180.0, jdStart, flags),
      southernSolstice: _swe.solCrossUt(270.0, jdStart, flags),
    );
  }
}
