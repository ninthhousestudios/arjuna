// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:logging/logging.dart';
import 'package:swisseph_rs/swisseph_rs.dart' as swe;

import 'asc_mc_points.dart';
import 'ayanamsa_sid_mode.dart';
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

final _log = Logger('SweFacade');

/// Facade over the Swiss Ephemeris library.
///
/// Wraps [swe.Ephemeris] to compute a complete [EphSnapshot] for a given time
/// and location. Each call to [calcAll] is stateless from the caller's
/// perspective — configuration flows through immutable handles and per-call
/// config overrides.
class SweFacade {
  final String? ephePath;
  final String? jplFile;

  // housesEx2/getAyanamsaUt read handle-level config (no per-call override),
  // so sidereal-mode-dependent calls need mode-keyed handles. Source is part
  // of the key because Swiss/JPL file opens are mutually exclusive per handle.
  final Map<(swe.EphemerisSource, swe.SiderealMode?), swe.Ephemeris> _handles =
      {};

  SweFacade.create({this.ephePath, this.jplFile}) {
    _handle(_defaultSource);
  }

  void dispose() {
    for (final h in _handles.values) {
      h.close();
    }
    _handles.clear();
  }

  swe.EphemerisSource get _defaultSource => ephePath != null
      ? swe.EphemerisSource.swiss
      : swe.EphemerisSource.moshier;

  swe.EphemerisSource _sourceFor(EphemerisSource requested) =>
      switch (requested) {
        EphemerisSource.swissEph => _defaultSource,
        EphemerisSource.moshier => swe.EphemerisSource.moshier,
        EphemerisSource.jplEph => swe.EphemerisSource.jpl,
      };

  swe.Ephemeris _handle(swe.EphemerisSource source, [swe.SiderealMode? mode]) =>
      _handles.putIfAbsent(
        (source, mode),
        () => swe.Ephemeris(
          swe.EphemerisConfig(
            ephemerisSource: source,
            ephePath: ephePath,
            jplFilename: jplFile,
            siderealMode: mode,
          ),
        ),
      );

  /// Compute a complete ephemeris snapshot.
  EphSnapshot calcAll(
    double jdUt,
    Location location,
    SweConfig sweConfig, {
    bool includeStarData = false,
  }) {
    final loc = location;
    final source = _sourceFor(sweConfig.ephemerisSource);
    final eph = _handle(source);
    final jd = swe.JdUt1(jdUt);

    _log.info(
      'calcAll jdUt=$jdUt bodies=${sweConfig.bodies.length} '
      'extraFrames=${sweConfig.extraFrames}',
    );

    // Fail-fast: barycentric is not supported under Moshier.
    if (sweConfig.extraFrames.contains(ReferencePoint.barycentric) &&
        sweConfig.ephemerisSource == EphemerisSource.moshier) {
      throw ArgumentError(
        'barycentric positions unsupported under Moshier; '
        'use EphemerisSource.swissEph or .jplEph',
      );
    }

    // Sidereal mode for per-call overrides.
    final isSidereal = !sweConfig.signAyanamsa.isTropical;
    final swe.SiderealMode? signMode =
        isSidereal && sweConfig.signAyanamsa.isStandard
        ? siderealModeFor(sweConfig.signAyanamsa)
        : null;

    // Topocentric config for per-call overrides.
    final swe.TopoPosition? topo = sweConfig.topocentric
        ? swe.TopoPosition(
            longitude: loc.longitude,
            latitude: loc.latitude,
            altitude: loc.altitude,
          )
        : null;

    final callConfig = swe.EphemerisConfig(
      siderealMode: signMode,
      topographic: topo,
    );

    // Base flags.
    var baseEclFlags =
        ephemerisFlag(sweConfig.ephemerisSource) | swe.CalcFlags.speed;
    if (isSidereal) baseEclFlags = baseEclFlags | swe.CalcFlags.sidereal;
    if (sweConfig.topocentric) {
      baseEclFlags = baseEclFlags | swe.CalcFlags.topoctr;
    }
    final equatorialFlags = baseEclFlags | swe.CalcFlags.equatorial;

    // Extra-frame flags strip topocentric — it is Earth-surface–specific and
    // meaningless against the SSB / Sun origin.
    var extraBase =
        ephemerisFlag(sweConfig.ephemerisSource) | swe.CalcFlags.speed;
    if (isSidereal) extraBase = extraBase | swe.CalcFlags.sidereal;

    final bodiesEcliptic = <Body, BodyPosition>{};
    final bodiesEquatorial = <Body, BodyPosition>{};
    final phenoResults = <Body, PhenoData>{};

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

      final sweBody = body == Body.rahu
          ? (sweConfig.trueNode ? swe.Body.trueNode : swe.Body.meanNode)
          : sweBodyFor(body);

      _log.fine('calc body=$body sweBody=$sweBody');

      final ecl = eph.calcUtWithConfig(jd, sweBody, baseEclFlags, callConfig);
      final equ = eph.calcUtWithConfig(
        jd,
        sweBody,
        equatorialFlags,
        callConfig,
      );

      final eclPos = _fromCalcResult(ecl);
      final equPos = _fromCalcResult(equ);

      bodiesEcliptic[body] = eclPos;
      bodiesEquatorial[body] = equPos;

      final pheno = _safePheno(eph, jd, body, sweBody, sweConfig, topo);
      if (pheno != null) phenoResults[body] = pheno;

      if (body == Body.rahu) {
        rahuEcl = eclPos;
        rahuEqu = equPos;
      }

      if (baryEcl != null) {
        final r = eph.calcUtWithConfig(
          jd,
          sweBody,
          extraBase | swe.CalcFlags.baryctr,
          callConfig,
        );
        final pos = _fromCalcResult(r);
        baryEcl[body] = pos;
        if (body == Body.rahu) rahuBaryEcl = pos;
      }
      if (helioEcl != null && body != Body.sun) {
        final r = eph.calcUtWithConfig(
          jd,
          sweBody,
          extraBase | swe.CalcFlags.helctr,
          callConfig,
        );
        final pos = _fromCalcResult(r);
        helioEcl[body] = pos;
        if (body == Body.rahu) rahuHelioEcl = pos;
      }
    }

    // Compute Ketu from Rahu if both are requested.
    if (sweConfig.bodies.contains(Body.ketu) &&
        rahuEcl != null &&
        rahuEqu != null) {
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
        final ecl = eph.fixstar2UtWithConfig(
          sweNameFor(star),
          jd,
          baseEclFlags,
          callConfig,
        );
        final equ = eph.fixstar2UtWithConfig(
          sweNameFor(star),
          jd,
          equatorialFlags,
          callConfig,
        );
        final data = includeStarData
            ? _calcStarData(eph, sweNameFor(star), jd, loc, sweConfig)
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
        final ecl = eph.fixstar2UtWithConfig(
          name,
          jd,
          baseEclFlags,
          callConfig,
        );
        final equ = eph.fixstar2UtWithConfig(
          name,
          jd,
          equatorialFlags,
          callConfig,
        );
        final data = includeStarData
            ? _calcStarData(eph, name, jd, loc, sweConfig)
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
            final ecl = eph.fixstar2UtWithConfig(
              '$name%',
              jd,
              baseEclFlags,
              callConfig,
            );
            final equ = eph.fixstar2UtWithConfig(
              '$name%',
              jd,
              equatorialFlags,
              callConfig,
            );
            final data = includeStarData
                ? _calcStarData(eph, name, jd, loc, sweConfig)
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
    final hsys = swe.HouseSystem.fromCharCode(
      sweConfig.houseSystem.sweChar.codeUnitAt(0),
    )!;
    final houseFlags = isSidereal ? swe.CalcFlags.sidereal : swe.CalcFlags.none;
    final housesEph = isSidereal ? _handle(source, signMode) : eph;
    final houseResult = housesEph.housesEx2(
      jd,
      houseFlags,
      loc.latitude,
      loc.longitude,
      hsys,
    );
    final cusps = List<double>.generate(12, (i) => houseResult.cusps[i + 1]);
    final ascmc = AscMcPoints(
      ascendant: houseResult.ascmc.ascendant,
      mc: houseResult.ascmc.mc,
      armc: houseResult.ascmc.armc,
      vertex: houseResult.ascmc.vertex,
      equatorialAscendant: houseResult.ascmc.equatorialAscendant,
      coAscendantKoch: houseResult.ascmc.coascendantKoch,
      coAscendantMunkasey: houseResult.ascmc.coascendantMunkasey,
      polarAscendant: houseResult.ascmc.polarAscendant,
    );

    // Ayanamsa value (sign frame).
    double ayanamsaValue = 0.0;
    if (isSidereal) {
      ayanamsaValue = _handle(
        source,
        signMode,
      ).getAyanamsaUt(jd, swe.CalcFlags.none);
      _log.fine('ayanamsa=$ayanamsaValue');
    }

    // ── Nakshatra-frame longitudes ──
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
        final sweBody = body == Body.rahu
            ? (sweConfig.trueNode ? swe.Body.trueNode : swe.Body.meanNode)
            : sweBodyFor(body);
        final equ = dhruvaGcEquatorial(eph, jdUt, sweBody);
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
          final equ = dhruvaGcEquatorialStar(eph, jdUt, sweNameFor(star));
          starsNakEclLon[star] = equ;
          starsNakEquLon[star] = equ;
        } catch (e) {
          _log.warning('dhruva nak calc failed for ${star.label}: $e');
        }
      }
      for (final name in sweConfig.customStarNames) {
        try {
          final equ = dhruvaGcEquatorialStar(eph, jdUt, name);
          customStarsNakEclLon[name] = equ;
          customStarsNakEquLon[name] = equ;
        } catch (_) {
          if (!name.endsWith('%')) {
            try {
              final equ = dhruvaGcEquatorialStar(eph, jdUt, '$name%');
              customStarsNakEclLon[name] = equ;
              customStarsNakEquLon[name] = equ;
            } catch (_) {}
          }
        }
      }
    } else {
      // Standard SWE ayanamsa or tropical, different from signAyanamsa.
      final swe.SiderealMode? nakMode =
          !nakAyanamsa.isTropical && nakAyanamsa.isStandard
          ? siderealModeFor(nakAyanamsa)
          : null;

      final nakCallConfig = swe.EphemerisConfig(
        siderealMode: nakMode,
        topographic: topo,
      );

      final swe.CalcFlags nakEclFlags;
      final swe.CalcFlags nakEquFlags;
      if (nakAyanamsa.isTropical) {
        var flags =
            ephemerisFlag(sweConfig.ephemerisSource) | swe.CalcFlags.speed;
        if (sweConfig.topocentric) flags = flags | swe.CalcFlags.topoctr;
        nakEclFlags = flags;
        nakEquFlags = flags | swe.CalcFlags.equatorial;
      } else {
        var flags =
            ephemerisFlag(sweConfig.ephemerisSource) |
            swe.CalcFlags.speed |
            swe.CalcFlags.sidereal;
        if (sweConfig.topocentric) flags = flags | swe.CalcFlags.topoctr;
        nakEclFlags = flags;
        nakEquFlags = flags | swe.CalcFlags.equatorial;
      }

      for (final body in sweConfig.bodies) {
        if (body == Body.ketu) continue;
        final sweBody = body == Body.rahu
            ? (sweConfig.trueNode ? swe.Body.trueNode : swe.Body.meanNode)
            : sweBodyFor(body);
        bodiesNakEclLon[body] = eph
            .calcUtWithConfig(jd, sweBody, nakEclFlags, nakCallConfig)
            .longitude;
        bodiesNakEquLon[body] = eph
            .calcUtWithConfig(jd, sweBody, nakEquFlags, nakCallConfig)
            .longitude;
      }
      if (sweConfig.bodies.contains(Body.ketu) &&
          bodiesNakEclLon.containsKey(Body.rahu)) {
        bodiesNakEclLon[Body.ketu] = (bodiesNakEclLon[Body.rahu]! + 180) % 360;
        bodiesNakEquLon[Body.ketu] = (bodiesNakEquLon[Body.rahu]! + 180) % 360;
      }
      for (final star in sweConfig.stars) {
        try {
          final sweName = sweNameFor(star);
          starsNakEclLon[star] = eph
              .fixstar2UtWithConfig(sweName, jd, nakEclFlags, nakCallConfig)
              .longitude;
          starsNakEquLon[star] = eph
              .fixstar2UtWithConfig(sweName, jd, nakEquFlags, nakCallConfig)
              .longitude;
        } catch (e) {
          _log.warning('fixstar nak calc failed for ${star.label}: $e');
        }
      }
      for (final name in sweConfig.customStarNames) {
        try {
          customStarsNakEclLon[name] = eph
              .fixstar2UtWithConfig(name, jd, nakEclFlags, nakCallConfig)
              .longitude;
          customStarsNakEquLon[name] = eph
              .fixstar2UtWithConfig(name, jd, nakEquFlags, nakCallConfig)
              .longitude;
        } catch (_) {
          if (!name.endsWith('%')) {
            try {
              customStarsNakEclLon[name] = eph
                  .fixstar2UtWithConfig(
                    '$name%',
                    jd,
                    nakEclFlags,
                    nakCallConfig,
                  )
                  .longitude;
              customStarsNakEquLon[name] = eph
                  .fixstar2UtWithConfig(
                    '$name%',
                    jd,
                    nakEquFlags,
                    nakCallConfig,
                  )
                  .longitude;
            } catch (_) {}
          }
        }
      }
    }

    // ── Cusp nakshatra-frame longitudes ──
    final List<double> cuspsNakLon;
    if (nakAyanamsa == sweConfig.signAyanamsa) {
      cuspsNakLon = cusps;
    } else if (!nakAyanamsa.isTropical && nakAyanamsa.isStandard) {
      final nakMode = siderealModeFor(nakAyanamsa);
      final nakHouse = _handle(source, nakMode).housesEx2(
        jd,
        swe.CalcFlags.sidereal,
        loc.latitude,
        loc.longitude,
        hsys,
      );
      cuspsNakLon = List.generate(12, (i) => nakHouse.cusps[i + 1]);
    } else if (nakAyanamsa.isTropical && isSidereal) {
      final nakHouse = eph.housesEx2(
        jd,
        swe.CalcFlags.none,
        loc.latitude,
        loc.longitude,
        hsys,
      );
      cuspsNakLon = List.generate(12, (i) => nakHouse.cusps[i + 1]);
    } else {
      cuspsNakLon = const [];
    }

    // Sunrise / sunset.
    final sunTimes = _calcSunTimes(eph, jd, loc, sweConfig);

    return EphSnapshot(
      jdUt: jdUt,
      location: location,
      sweConfig: sweConfig,
      bodiesEcliptic: bodiesEcliptic,
      bodiesEquatorial: bodiesEquatorial,
      phenoData: phenoResults,
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
      cuspsNakLon: cuspsNakLon,
      bodiesEclipticBarycentric: baryEcl,
      bodiesEclipticHeliocentric: helioEcl,
      stars: starsMap,
      customStars: customStarsMap,
    );
  }

  BodyPosition _fromCalcResult(swe.CalcResult r) => BodyPosition(
    longitude: r.longitude,
    latitude: r.latitude,
    distance: r.distance,
    speedLongitude: r.longitudeSpeed,
    speedLatitude: r.latitudeSpeed,
    speedDistance: r.distanceSpeed,
  );

  BodyPosition _fromFixstarResult(swe.FixstarResult r) => BodyPosition(
    longitude: r.longitude,
    latitude: r.latitude,
    distance: r.distance,
    speedLongitude: r.longitudeSpeed,
    speedLatitude: r.latitudeSpeed,
    speedDistance: r.distanceSpeed,
  );

  PhenoData? _safePheno(
    swe.Ephemeris eph,
    swe.JdUt1 jd,
    Body body,
    swe.Body sweBody,
    SweConfig sweConfig,
    swe.TopoPosition? topo,
  ) {
    if (body == Body.rahu || body == Body.ketu) return null;
    final phenoFlags =
        ephemerisFlag(sweConfig.ephemerisSource) |
        swe.CalcFlags.speed |
        (sweConfig.topocentric ? swe.CalcFlags.topoctr : swe.CalcFlags.none);
    final phenoConfig = swe.EphemerisConfig(topographic: topo);
    try {
      final r = eph.phenoUtWithConfig(jd, sweBody, phenoFlags, phenoConfig);
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

  StarData _calcStarData(
    swe.Ephemeris eph,
    String sweName,
    swe.JdUt1 jd,
    Location loc,
    SweConfig sweConfig,
  ) {
    double? mag;
    try {
      mag = eph.fixstar2Mag(sweName).magnitude;
    } catch (e) {
      _log.fine('fixstar2Mag failed for $sweName: $e');
    }

    double? riseJd;
    double? setJd;
    bool riseCircumpolar = false;
    bool setCircumpolar = false;

    final epheFlags = ephemerisFlag(sweConfig.ephemerisSource);

    try {
      riseJd = eph
          .riseTrans(
            jd,
            swe.Body.sun,
            epheFlags,
            swe.RiseSetFlags.rise,
            starname: sweName,
            geolon: loc.longitude,
            geolat: loc.latitude,
            geoalt: loc.altitude,
          )
          .time;
    } on swe.CircumpolarBodyException {
      riseCircumpolar = true;
    } on swe.SweException catch (e) {
      _log.warning('star rise failed for $sweName: $e');
    }

    try {
      setJd = eph
          .riseTrans(
            jd,
            swe.Body.sun,
            epheFlags,
            swe.RiseSetFlags.set,
            starname: sweName,
            geolon: loc.longitude,
            geolat: loc.latitude,
            geoalt: loc.altitude,
          )
          .time;
    } on swe.CircumpolarBodyException {
      setCircumpolar = true;
    } on swe.SweException catch (e) {
      _log.warning('star set failed for $sweName: $e');
    }

    return StarData(
      apparentMagnitude: mag,
      riseJd: riseJd,
      setJd: setJd,
      circumpolar: riseCircumpolar || setCircumpolar,
    );
  }

  SunTimes _calcSunTimes(
    swe.Ephemeris eph,
    swe.JdUt1 jd,
    Location loc,
    SweConfig sweConfig,
  ) {
    double? sunrise;
    double? sunset;

    final epheFlags = ephemerisFlag(sweConfig.ephemerisSource);

    try {
      sunrise = eph
          .riseTrans(
            jd,
            swe.Body.sun,
            epheFlags,
            swe.RiseSetFlags.rise,
            geolon: loc.longitude,
            geolat: loc.latitude,
            geoalt: loc.altitude,
          )
          .time;
    } on swe.CircumpolarBodyException {
      // Polar day/night — no rise event.
    } on swe.SweException catch (e) {
      _log.warning('sunrise calc failed: $e');
    }

    try {
      sunset = eph
          .riseTrans(
            jd,
            swe.Body.sun,
            epheFlags,
            swe.RiseSetFlags.set,
            geolon: loc.longitude,
            geolat: loc.latitude,
            geoalt: loc.altitude,
          )
          .time;
    } on swe.CircumpolarBodyException {
      // Polar day/night — no set event.
    } on swe.SweException catch (e) {
      _log.warning('sunset calc failed: $e');
    }

    return SunTimes(sunrise: sunrise, sunset: sunset);
  }

  /// Ayanamsa value (arc-degrees) for ephemeris time [jdEt] under [ayanamsa].
  ///
  /// Returns 0.0 for tropical. For non-tropical standard ayanamsas, uses
  /// a handle constructed with the appropriate sidereal mode.
  double getAyanamsa(double jdEt, Ayanamsa ayanamsa) {
    if (ayanamsa.isTropical) return 0.0;
    return _handle(
      _defaultSource,
      siderealModeFor(ayanamsa),
    ).getAyanamsaEx(swe.JdTt(jdEt), swe.CalcFlags.none);
  }

  /// Ayanamsa value (arc-degrees) for universal time [jdUt] under [ayanamsa].
  double getAyanamsaUt(double jdUt, Ayanamsa ayanamsa) {
    if (ayanamsa.isTropical) return 0.0;
    return _handle(
      _defaultSource,
      siderealModeFor(ayanamsa),
    ).getAyanamsaUt(swe.JdUt1(jdUt), swe.CalcFlags.none);
  }

  /// Sidereal ecliptic longitude of [sweId] at [jdUt] under [ayanamsa].
  double calcSiderealLongitude(double jdUt, int sweId, Ayanamsa ayanamsa) {
    assert(ayanamsa.isStandard);
    final flags =
        swe.CalcFlags.swiEph | swe.CalcFlags.speed | swe.CalcFlags.sidereal;
    return _handle(_defaultSource)
        .calcUtWithConfig(
          swe.JdUt1(jdUt),
          swe.Body.fromRawId(sweId),
          flags,
          swe.EphemerisConfig(siderealMode: siderealModeFor(ayanamsa)),
        )
        .longitude;
  }

  /// Dhruva GC mid-Mula Equatorial longitude for [sweId] at [jdUt].
  double calcDhruvaLongitude(double jdUt, int sweId) {
    return dhruvaGcEquatorial(
      _handle(_defaultSource),
      jdUt,
      swe.Body.fromRawId(sweId),
    );
  }

  /// Find the four tropical cardinal points of calendar [year].
  CardinalPoints calcCardinalPoints(
    int year, {
    EphemerisSource source = EphemerisSource.swissEph,
  }) {
    final eph = _handle(_sourceFor(source));
    final jdStart = swe.julday(year, 1, 1, 0.0, swe.CalendarType.gregorian);
    final flags = ephemerisFlag(source);
    _log.info('calcCardinalPoints year=$year jdStart=$jdStart');
    return CardinalPoints(
      ascendingEquinox: eph.solcrossUt(0.0, jdStart, flags),
      northernSolstice: eph.solcrossUt(90.0, jdStart, flags),
      descendingEquinox: eph.solcrossUt(180.0, jdStart, flags),
      southernSolstice: eph.solcrossUt(270.0, jdStart, flags),
    );
  }
}
