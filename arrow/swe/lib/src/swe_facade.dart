import 'package:arrow_options/arrow_options.dart';
import 'package:logging/logging.dart';
import 'package:swisseph/swisseph.dart';

import 'asc_mc_points.dart';
import 'body_position.dart';
import 'body_swe_id.dart';
import 'cardinal_points.dart';
import 'dhruva.dart';
import 'eph_snapshot.dart';
import 'ephemeris_flag.dart';
import 'pheno_data.dart';
import 'star_data.dart';
import 'star_position.dart';
import 'star_swe_name.dart';
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
  EphSnapshot calcAll(
    double jdUt,
    Location location,
    SweConfig sweConfig, {
    bool includeStarData = false,
  }) {
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
          : sweIdFor(body);

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

    // Fixed stars — build StarPosition (ecliptic + equatorial + optional data).
    final starsMap = <Star, StarPosition>{};
    for (final star in sweConfig.stars) {
      _log.fine('calc star=${star.label} sweName=${sweNameFor(star)}');
      try {
        final ecl = _swe.fixstar2Ut(sweNameFor(star), jdUt, baseEclFlags);
        final equ = _swe.fixstar2Ut(sweNameFor(star), jdUt, equatorialFlags);
        final data = includeStarData
            ? _calcStarData(sweNameFor(star), jdUt, loc, sweConfig)
            : null;
        starsMap[star] = StarPosition(
          ecliptic: _fromFixstarResult(ecl),
          equatorial: _fromFixstarResult(equ),
          starData: data,
        );
      } catch (e) {
        _log.warning('fixstar calc failed for ${star.label}: $e');
      }
    }

    // Custom star names (arbitrary SWE nomen strings with % fallback).
    final customStarsMap = <String, StarPosition>{};
    for (final name in sweConfig.customStarNames) {
      _log.fine('calc customStar=$name');
      try {
        final ecl = _swe.fixstar2Ut(name, jdUt, baseEclFlags);
        final equ = _swe.fixstar2Ut(name, jdUt, equatorialFlags);
        final data = includeStarData
            ? _calcStarData(name, jdUt, loc, sweConfig)
            : null;
        customStarsMap[name] = StarPosition(
          ecliptic: _fromFixstarResult(ecl),
          equatorial: _fromFixstarResult(equ),
          starData: data,
        );
      } catch (_) {
        if (!name.endsWith('%')) {
          _log.fine('fixstar exact match failed for $name, retrying with %');
          try {
            final ecl = _swe.fixstar2Ut('$name%', jdUt, baseEclFlags);
            final equ = _swe.fixstar2Ut('$name%', jdUt, equatorialFlags);
            final data = includeStarData
                ? _calcStarData(name, jdUt, loc, sweConfig)
                : null;
            customStarsMap[name] = StarPosition(
              ecliptic: _fromFixstarResult(ecl),
              equatorial: _fromFixstarResult(equ),
              starData: data,
            );
          } catch (e2) {
            _log.warning('fixstar calc failed for custom star $name: $e2');
          }
        } else {
          _log.warning('fixstar calc failed for custom star $name');
        }
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

    // Ayanamsa value (sign frame).
    double ayanamsaValue = 0.0;
    if (isSidereal) {
      ayanamsaValue = _swe.getAyanamsaUt(jdUt);
      _log.fine('ayanamsa=$ayanamsaValue');
    }

    // ── Nakshatra-frame longitudes ──
    // Computed AFTER all sign-frame work is done (including getAyanamsaUt).
    // SWE sidereal mode may change here — nothing after this depends on it.
    final nakAyanamsa = sweConfig.nakAyanamsa;
    _log.fine('nakAyanamsa=${nakAyanamsa.label}');

    final bodiesNakEclLon = <Body, double>{};
    final bodiesNakEquLon = <Body, double>{};
    final starsNakEclLon = <Star, double>{};
    final starsNakEquLon = <Star, double>{};
    final customStarsNakEclLon = <String, double>{};
    final customStarsNakEquLon = <String, double>{};

    if (nakAyanamsa == sweConfig.signAyanamsa) {
      // Nak frame == sign frame. Extract longitudes from existing positions.
      for (final e in bodiesEcliptic.entries) {
        bodiesNakEclLon[e.key] = e.value.longitude;
      }
      for (final e in bodiesEquatorial.entries) {
        bodiesNakEquLon[e.key] = e.value.longitude;
      }
      for (final e in starsMap.entries) {
        starsNakEclLon[e.key] = e.value.ecliptic.longitude;
        starsNakEquLon[e.key] = e.value.equatorial.longitude;
      }
      for (final e in customStarsMap.entries) {
        customStarsNakEclLon[e.key] = e.value.ecliptic.longitude;
        customStarsNakEquLon[e.key] = e.value.equatorial.longitude;
      }
    } else if (nakAyanamsa == Ayanamsa.dhruva) {
      // Dhruva is equatorial-only. Ecliptic maps store the same value.
      for (final body in sweConfig.bodies) {
        if (body == Body.ketu) continue;
        final sweId = body == Body.rahu
            ? (sweConfig.trueNode ? seTrueNode : seMeanNode)
            : sweIdFor(body);
        final equ = dhruvaGcEquatorial(_swe, jdUt, sweId);
        bodiesNakEclLon[body] = equ;
        bodiesNakEquLon[body] = equ;
      }
      if (sweConfig.bodies.contains(Body.ketu) &&
          bodiesNakEquLon.containsKey(Body.rahu)) {
        final ketuNak = (bodiesNakEquLon[Body.rahu]! + 180) % 360;
        bodiesNakEclLon[Body.ketu] = ketuNak;
        bodiesNakEquLon[Body.ketu] = ketuNak;
      }
      for (final star in sweConfig.stars) {
        try {
          final equ =
              dhruvaGcEquatorialStar(_swe, jdUt, sweNameFor(star));
          starsNakEclLon[star] = equ;
          starsNakEquLon[star] = equ;
        } catch (e) {
          _log.warning('dhruva nak calc failed for ${star.label}: $e');
        }
      }
      for (final name in sweConfig.customStarNames) {
        try {
          final equ = dhruvaGcEquatorialStar(_swe, jdUt, name);
          customStarsNakEclLon[name] = equ;
          customStarsNakEquLon[name] = equ;
        } catch (_) {
          if (!name.endsWith('%')) {
            try {
              final equ = dhruvaGcEquatorialStar(_swe, jdUt, '$name%');
              customStarsNakEclLon[name] = equ;
              customStarsNakEquLon[name] = equ;
            } catch (_) {}
          }
        }
      }
    } else {
      // Standard SWE ayanamsa or tropical, different from signAyanamsa.
      // setSidMode changes global SWE state — safe because sign-frame work
      // (including getAyanamsaUt) is already complete.
      final int nakEclFlags;
      final int nakEquFlags;
      if (nakAyanamsa.isTropical) {
        nakEclFlags = ephemerisFlag(sweConfig.ephemerisSource) |
            seFlgSpeed |
            (sweConfig.topocentric ? seFlgTopoCtr : 0);
        nakEquFlags = nakEclFlags | seFlgEquatorial;
      } else {
        _swe.setSidMode(nakAyanamsa.sweCode);
        nakEclFlags = ephemerisFlag(sweConfig.ephemerisSource) |
            seFlgSpeed |
            seFlgSidereal |
            (sweConfig.topocentric ? seFlgTopoCtr : 0);
        nakEquFlags = nakEclFlags | seFlgEquatorial;
      }

      for (final body in sweConfig.bodies) {
        if (body == Body.ketu) continue;
        final sweId = body == Body.rahu
            ? (sweConfig.trueNode ? seTrueNode : seMeanNode)
            : sweIdFor(body);
        bodiesNakEclLon[body] =
            _swe.calcUt(jdUt, sweId, nakEclFlags).longitude;
        bodiesNakEquLon[body] =
            _swe.calcUt(jdUt, sweId, nakEquFlags).longitude;
      }
      if (sweConfig.bodies.contains(Body.ketu) &&
          bodiesNakEclLon.containsKey(Body.rahu)) {
        bodiesNakEclLon[Body.ketu] =
            (bodiesNakEclLon[Body.rahu]! + 180) % 360;
        bodiesNakEquLon[Body.ketu] =
            (bodiesNakEquLon[Body.rahu]! + 180) % 360;
      }
      for (final star in sweConfig.stars) {
        try {
          final sweName = sweNameFor(star);
          starsNakEclLon[star] =
              _swe.fixstar2Ut(sweName, jdUt, nakEclFlags).longitude;
          starsNakEquLon[star] =
              _swe.fixstar2Ut(sweName, jdUt, nakEquFlags).longitude;
        } catch (e) {
          _log.warning('fixstar nak calc failed for ${star.label}: $e');
        }
      }
      for (final name in sweConfig.customStarNames) {
        try {
          customStarsNakEclLon[name] =
              _swe.fixstar2Ut(name, jdUt, nakEclFlags).longitude;
          customStarsNakEquLon[name] =
              _swe.fixstar2Ut(name, jdUt, nakEquFlags).longitude;
        } catch (_) {
          if (!name.endsWith('%')) {
            try {
              customStarsNakEclLon[name] =
                  _swe.fixstar2Ut('$name%', jdUt, nakEclFlags).longitude;
              customStarsNakEquLon[name] =
                  _swe.fixstar2Ut('$name%', jdUt, nakEquFlags).longitude;
            } catch (_) {}
          }
        }
      }
    }

    // Sunrise / sunset.
    final sunTimes = _calcSunTimes(jdUt, loc);

    return EphSnapshot(
      jdUt: jdUt,
      location: location,
      sweConfig: sweConfig,
      bodiesEcliptic: bodiesEcliptic,
      bodiesEquatorial: bodiesEquatorial,
      phenoData: phenoData,
      cusps: cusps,
      ascmc: ascmc,
      sunTimes: sunTimes,
      ayanamsaValue: ayanamsaValue,
      bodiesNakEclLon: bodiesNakEclLon,
      bodiesNakEquLon: bodiesNakEquLon,
      starsNakEclLon: starsNakEclLon,
      starsNakEquLon: starsNakEquLon,
      customStarsNakEclLon: customStarsNakEclLon,
      customStarsNakEquLon: customStarsNakEquLon,
      bodiesEclipticBarycentric: baryEcl,
      bodiesEclipticHeliocentric: helioEcl,
      stars: starsMap,
      customStars: customStarsMap,
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

  BodyPosition _fromFixstarResult(FixstarResult r) => BodyPosition(
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

  StarData _calcStarData(
    String sweName,
    double jdUt,
    Location loc,
    SweConfig sweConfig,
  ) {
    double? mag;
    try {
      mag = _swe.fixstar2Mag(sweName);
    } catch (e) {
      _log.fine('fixstar2Mag failed for $sweName: $e');
    }

    double? riseJd;
    double? setJd;
    bool riseFailed = false;
    bool setFailed = false;

    try {
      final r = _swe.riseTrans(
        jdUt,
        0,
        starName: sweName,
        rsmi: seCalcRise,
        geolon: loc.longitude,
        geolat: loc.latitude,
        geoalt: loc.altitude,
      );
      riseJd = r.transitTime;
    } catch (e) {
      _log.warning('star rise failed for $sweName: $e');
      riseFailed = true;
    }

    try {
      final r = _swe.riseTrans(
        jdUt,
        0,
        starName: sweName,
        rsmi: seCalcSet,
        geolon: loc.longitude,
        geolat: loc.latitude,
        geoalt: loc.altitude,
      );
      setJd = r.transitTime;
    } catch (e) {
      _log.warning('star set failed for $sweName: $e');
      setFailed = true;
    }

    // Only mark circumpolar when both rise and set fail — a single failure
    // could be a genuine circumpolar condition or an input/ephemeris error,
    // but both failing strongly implies a circumpolar star at this latitude.
    // TODO: inspect SWE error codes when the Dart binding exposes them to
    // distinguish circumpolar from calculation errors more precisely.
    final circumpolar = riseFailed && setFailed;

    return StarData(
      apparentMagnitude: mag,
      riseJd: riseJd,
      setJd: setJd,
      circumpolar: circumpolar,
    );
  }

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

  /// Sidereal ecliptic longitude of [sweId] at [jdUt] under [ayanamsa].
  ///
  /// Sets the SWE sidereal mode and computes directly in the sidereal frame,
  /// rather than computing tropical and subtracting. Only for standard SWE
  /// ayanamsas (codes 0–96).
  double calcSiderealLongitude(double jdUt, int sweId, Ayanamsa ayanamsa) {
    assert(ayanamsa.isStandard);
    _swe.setSidMode(ayanamsa.sweCode);
    final flags = ephemerisFlag(EphemerisSource.swissEph) |
        seFlgSpeed |
        seFlgSidereal;
    final r = _swe.calcUt(jdUt, sweId, flags);
    return r.longitude;
  }

  /// Dhruva GC mid-Mula Equatorial longitude for [sweId] at [jdUt].
  ///
  /// Delegates to the free function [dhruvaGcEquatorial] which anchors
  /// the nakshatra system equatorially on Sgr A*.
  double calcDhruvaLongitude(double jdUt, int sweId) =>
      dhruvaGcEquatorial(_swe, jdUt, sweId);

  /// Find the four tropical cardinal points of calendar [year]: the JDs (UT)
  /// at which the Sun reaches tropical longitudes 0°, 90°, 180°, 270°.
  ///
  /// [source] selects the underlying ephemeris — defaults to Swiss Ephemeris.
  /// Sidereal and topocentric settings from [SweConfig] are irrelevant:
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
