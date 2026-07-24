// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Compile-check for the API surface documented in `arrow/docs/api-reference.md`.
///
/// That reference is hand-maintained with no generation step, and it went fully
/// stale across all four packages after the swisseph_rs migration without
/// anything failing (arrow/12). This file pins it: every constructor, method
/// signature, field name, and return type the reference claims is referenced
/// below, so renaming or resignaturing a documented symbol breaks the build
/// instead of silently rotting the doc.
///
/// The probes are **compile-only** — they are collected into [_probes] but never
/// called, so no SWE handle, native library, or ephemeris file is needed at test
/// runtime. When you change a documented API, fix the probe *and* the doc.
library;

// `Nakshatra` is declared twice across the barrels: the chart-context class in
// arrow_core and the panchanga limb in arrow_calc. Consumers importing both
// barrels must disambiguate — the doc says so, and this import proves it.
import 'package:arrow_calc/arrow_calc.dart' hide Nakshatra;
import 'package:arrow_calc/arrow_calc.dart' as panchanga show Nakshatra;
import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

/// Consumes a probed value so the reference counts as a use.
void _use(Object? value) {}

// ---------------------------------------------------------------------------
// Options layer — api-reference.md § Options layer
// ---------------------------------------------------------------------------

void _validateSurface(ArrowOptions options) {
  options.validate();
}

void _optionsSurface() {
  const options = ArrowOptions(
    sweConfig: SweConfig(),
    calcConfig: CalcConfig(),
  );
  _use([options.sweConfig, options.calcConfig]);

  const swe = SweConfig(
    bodies: {Body.sun, Body.moon},
    signAyanamsa: Ayanamsa.tropical,
    houseSystem: HouseSystem.campanus,
    trueNode: true,
    topocentric: false,
    ephemerisSource: EphemerisSource.swissEph,
    extraFrames: {ReferencePoint.heliocentric},
    stars: {},
    customStarNames: {},
    nakAyanamsa: Ayanamsa.dhruva,
  );
  _use([
    swe.bodies,
    swe.signAyanamsa,
    swe.houseSystem,
    swe.trueNode,
    swe.topocentric,
    swe.ephemerisSource,
    swe.extraFrames,
    swe.stars,
    swe.customStarNames,
    swe.nakAyanamsa,
  ]);

  const calc = CalcConfig(
    circle: Circle.aditya,
    nakEquatorial: true,
    traditions: {Tradition.vedic},
    zodiacSystem: ZodiacSystem.tropical12,
    vedic: VedicConfig(),
  );
  _use([
    calc.circle,
    calc.nakEquatorial,
    calc.traditions,
    calc.zodiacSystem,
    calc.vedic,
  ]);

  const loc = Location(latitude: 28.6, longitude: 77.2, altitude: 0.0);
  _use([loc.latitude, loc.longitude, loc.altitude]);

  _use([
    ArrowPresets.aditya,
    ArrowPresets.lahiriVedic,
    ArrowPresets.westernTropical,
  ]);
}

// ---------------------------------------------------------------------------
// SWE layer — api-reference.md § SWE layer
// ---------------------------------------------------------------------------

void _sweFacadeSurface() {
  final facade = SweFacade.create(ephePath: null, jplFile: null);
  _use([facade.ephePath, facade.jplFile]);

  const loc = Location(latitude: 28.6, longitude: 77.2);
  const config = SweConfig();
  const jd = 2451545.0;

  final EphSnapshot snap = facade.calcAll(
    jd,
    loc,
    config,
    includeStarData: true,
  );
  _use(snap);

  final double etAyanamsa = facade.getAyanamsa(jd, Ayanamsa.lahiri);
  final double utAyanamsa = facade.getAyanamsaUt(jd, Ayanamsa.dhruva);
  final double sidereal = facade.calcSiderealLongitude(jd, 0, Ayanamsa.lahiri);
  final double dhruva = facade.calcDhruvaLongitude(jd, 0);
  _use([etAyanamsa, utAyanamsa, sidereal, dhruva]);

  final double house = facade.housePosition(
    jd,
    loc,
    config,
    longitude: 12.0,
    latitude: 0.0,
    houseSystem: HouseSystem.campanus,
  );
  _use(house);

  final CardinalPoints cardinals = facade.calcCardinalPoints(
    2026,
    source: EphemerisSource.swissEph,
  );
  _use([
    cardinals.ascendingEquinox,
    cardinals.northernSolstice,
    cardinals.descendingEquinox,
    cardinals.southernSolstice,
  ]);

  facade.dispose();
}

void _snapshotSurface(EphSnapshot snap) {
  final Map<Body, BodyPosition> ecliptic = snap.bodiesEcliptic;
  final Map<Body, BodyPosition> equatorial = snap.bodiesEquatorial;
  final Map<Body, PhenoData> pheno = snap.phenoData;
  final List<double> cusps = snap.cusps;
  _use([
    snap.jdUt,
    snap.location,
    snap.sweConfig,
    ecliptic,
    equatorial,
    pheno,
    cusps,
    snap.ascmc,
    snap.sunTimes,
    snap.ayanamsaValue,
  ]);

  final Map<Body, double> nakEcl = snap.bodiesNakEclLon;
  final Map<Body, double> nakEqu = snap.bodiesNakEquLon;
  final Map<Star, double> starNakEcl = snap.starsNakEclLon;
  final Map<Star, double> starNakEqu = snap.starsNakEquLon;
  final Map<String, double> customNakEcl = snap.customStarsNakEclLon;
  final Map<String, double> customNakEqu = snap.customStarsNakEquLon;
  final List<double> cuspsNak = snap.cuspsNakLon;
  _use([
    nakEcl,
    nakEqu,
    starNakEcl,
    starNakEqu,
    customNakEcl,
    customNakEqu,
    cuspsNak,
  ]);

  final Map<Body, BodyPosition>? bary = snap.bodiesEclipticBarycentric;
  final Map<Body, BodyPosition>? helio = snap.bodiesEclipticHeliocentric;
  final Map<Star, StarPosition> stars = snap.stars;
  final Map<String, StarPosition> customStars = snap.customStars;
  _use([bary, helio, stars, customStars]);
}

void _snapshotValueTypes(
  AscMcPoints ascmc,
  BodyPosition pos,
  PhenoData pheno,
  StarPosition starPos,
  StarData starData,
  SunTimes times,
) {
  _use([
    ascmc.ascendant,
    ascmc.mc,
    ascmc.armc,
    ascmc.vertex,
    ascmc.equatorialAscendant,
    ascmc.coAscendantKoch,
    ascmc.coAscendantMunkasey,
    ascmc.polarAscendant,
  ]);
  _use([
    pos.longitude,
    pos.latitude,
    pos.distance,
    pos.speedLongitude,
    pos.speedLatitude,
    pos.speedDistance,
  ]);
  _use([
    pheno.phaseAngle,
    pheno.phase,
    pheno.elongation,
    pheno.apparentDiameter,
    pheno.apparentMagnitude,
  ]);
  _use([starPos.ecliptic, starPos.equatorial, starPos.starData]);
  _use([
    starData.apparentMagnitude,
    starData.riseJd,
    starData.setJd,
    starData.circumpolar,
  ]);
  _use([times.sunrise, times.sunset]);
}

void _julianDaySurface() {
  final double jd = julianDay(DateTime.utc(1990, 3, 17, 12, 30));
  final DateTime back = fromJulianDay(jd);
  _use([jd, back]);
}

// ---------------------------------------------------------------------------
// Core layer — api-reference.md § Core layer
// ---------------------------------------------------------------------------

void _chartSurface(EphSnapshot snap) {
  const config = CalcConfig();
  final chart = Chart(snap, config);

  final Rashi rashi = chart.rashi;
  final Map<Star, FixedStar> stars = chart.fixedStars;
  final Map<String, FixedStar> customStars = chart.customFixedStars;
  _use([chart.snapshot, chart.config, rashi, stars, customStars]);

  final Varga navamsha = chart.varga(VargaType.navamsha);
  _use(navamsha);

  final List<Karaka> karakas = chart.karakas;
  final List<Planet> grahas = chart.grahas;
  final List<Planet> planets = chart.planets;
  _use([
    chart.sun,
    chart.moon,
    chart.mars,
    chart.mercury,
    chart.jupiter,
    chart.venus,
    chart.saturn,
    chart.rahu,
    chart.ketu,
    karakas,
    grahas,
    planets,
  ]);

  final List<Cusp> cusps = chart.cusps;
  final Cusp first = chart.cusp(1);
  _use([cusps, first, chart.ascendant, chart.mc]);

  final Map<Body, SynodicState> synodic = chart.synodicStates;
  _use(synodic);
}

void _vargaSurface(
  Varga varga,
  Rashi rashi,
  Sign sign,
  Nakshatra nak,
  Cusp cusp,
) {
  _use([
    varga.planet(Body.sun),
    varga.cusps,
    varga.karakas,
    varga.grahas,
    varga.planets,
    varga.sun,
    varga.rahu,
  ]);

  final Map<int, Nakshatra> nakshatras = rashi.nakshatras;
  _use([nakshatras, rashi.nakshatraOf(rashi.rahu)]);

  _use([
    sign.number,
    sign.lord,
    sign.element,
    sign.quality,
    sign.gender,
    sign.name,
    sign.planets,
    sign.cusps,
  ]);
  _use([nak.number, nak.lord, nak.deity, nak.name, nak.planets]);
  _use([cusp.house, cusp.longitude, cusp.sign, cusp.nakshatra, cusp.pada]);
}

void _skyObjectSurface(SkyObject obj) {
  _use([
    obj.position,
    obj.equatorialPosition,
    obj.config,
    obj.vargaType,
    obj.rawLongitude,
    obj.rawEquatorialLongitude,
    obj.nakLongitude,
    obj.longitude,
    obj.varga(VargaType.navamsha),
    obj.sign,
    obj.nakshatra,
    obj.pada,
    obj.hora,
    obj.beingType,
    obj.trimsamsaBeing,
    obj.horaBeing,
  ]);
}

void _bodySurface(EphSnapshot snap, Karaka karaka, FixedStar star) {
  const config = CalcConfig();
  final body = CelestialBody(Body.sun, snap, config, VargaType.rashi);
  _use([
    body.body,
    body.snapshot,
    body.barycentricPosition,
    body.heliocentricPosition,
    body.barycentricRashiLongitude,
    body.heliocentricRashiLongitude,
  ]);

  final planet = Planet(Body.rahu, snap, config, VargaType.rashi);
  final bool retro = planet.isRetrograde;
  final Direction dir = planet.direction;
  final SpeedClass speed = planet.speedClass;
  final PhenoData? pheno = planet.pheno;
  final SynodicState? synodic = planet.synodicState;
  _use([retro, dir, speed, pheno, synodic]);

  final withSun = Karaka(
    Body.sun,
    snap,
    config,
    VargaType.rashi,
    sunLongitude: 12.0,
  );
  _use(withSun);

  final double inSign = karaka.inSignLongitude;
  final DignityType dignity = karaka.dignity;
  final bool combust = karaka.isCombust;
  _use([inSign, dignity, combust]);

  _use([star.star, star.name, star.junctionOf, star.starData, star.magnitude]);
}

void _longitudeSurface() {
  const config = CalcConfig();
  final lon = Longitude(123.4, VargaType.rashi, config, nakLongitude: 100.0);
  _use([
    lon.eclipticLongitude,
    lon.vargaType,
    lon.config,
    lon.nakLongitude,
    lon.amshaLongitude,
    lon.amsha,
    lon.longitude,
    lon.deity,
    lon.sign,
    lon.signIndex,
    lon.nakshatra,
    lon.pada,
    lon.inSignLongitude,
    lon.degreesApart(10.0),
    lon.signsApart(4),
    lon.isBetween(10.0, 20.0),
  ]);
}

void _dignitySurface() {
  _use([
    Dignity.exaltation,
    Dignity.debilitation,
    Dignity.moolatrikona,
    Dignity.ownSigns,
    Dignity.combustionOrbs,
    Dignity.calculate(Body.sun, 1, 10.0, 5),
    Dignity.isCombust(Body.mercury, 10.0, 12.0, isRetrograde: false),
    Dignity.isExalted(Body.sun, 1, 10.0),
    Dignity.isDebilitated(Body.sun, 7, 10.0),
    Dignity.isMoolatrikona(Body.sun, 5, 10.0),
    Dignity.isOwnSign(Body.sun, 5, 10.0),
    Dignity.isNaturalFriend(Body.sun, Body.moon),
    Dignity.isNaturalEnemy(Body.sun, Body.venus),
    Dignity.isTemporaryFriend(1, 2),
    Dignity.compoundFriendship(Body.sun, Body.moon, 1, 2),
  ]);
  _use([
    DignityType.exalted,
    DignityType.moolatrikona,
    DignityType.ownSign,
    DignityType.greatFriend,
    DignityType.friend,
    DignityType.neutral,
    DignityType.enemy,
    DignityType.greatEnemy,
    DignityType.debilitated,
    FriendshipType.compound,
    FriendshipLevel.greatFriend,
  ]);
}

void _motionSurface(PhenoData pheno) {
  final Direction dir = directionOf(Body.mars, 0.5);
  final SpeedClass speed = classifySpeed(Body.mars, 0.5);
  final ElongationCategory cat = ElongationCategory.of(90.0);
  _use([
    dir,
    speed,
    cat,
    Direction.direct,
    Direction.stationary,
    Direction.retrograde,
    SpeedClass.fast,
    SpeedClass.mean,
    SpeedClass.slow,
    SpeedClass.stationary,
    ElongationCategory.conjunction,
    ElongationCategory.nearConjunction,
    ElongationCategory.earlyElongation,
    ElongationCategory.quadrature,
    ElongationCategory.gibbous,
    ElongationCategory.opposition,
  ]);

  final state = SynodicState.from(
    body: Body.moon,
    bodyLongitude: 100.0,
    sunLongitude: 10.0,
    pheno: pheno,
  );
  final bool? waxing = state.isWaxing;
  _use([state.pheno, state.category, waxing]);
}

void _charaKarakaSurface(List<Karaka> karakas) {
  final Map<CharaKarakaRole, Karaka> roles = CharaKaraka.assign(karakas);
  _use(roles);
}

// ---------------------------------------------------------------------------
// Calc layer — api-reference.md § Calc layer
// ---------------------------------------------------------------------------

void _avasthaSurface(Varga varga) {
  final BaladiState baladi = Baladi.of(1, 12.0);
  final JagradadiState jagradadi = Jagradadi.of(DignityType.exalted);
  final DeeptadiState deeptadi = Deeptadi.of(Body.sun, varga);
  _use([baladi, jagradadi, deeptadi]);

  final Map<Body, LajjitaadiResult> lajjitaadi = Lajjitaadi.compute(varga);
  _use(lajjitaadi);
}

void _lajjitaadiTypes(LajjitaadiFactor factor, LajjitaadiResult result) {
  _use([
    factor.source,
    factor.planet,
    factor.lord,
    factor.strength,
    factor.dignity,
    factor.detail,
    factor.to,
  ]);
  _use([result.avasthas, result.receiving, result.giving]);
  _use([
    LajjitaadiState.delighted,
    LajjitaadiState.starved,
    LajjitaadiState.agitated,
    LajjitaadiState.thirsty,
    LajjitaadiState.shamed,
    LajjitaadiState.healthy,
    LajjitaadiState.proud,
  ]);
}

void _aspectSurface(Varga varga) {
  _use([
    Aspect.strength(Body.mars, 10.0, 100.0),
    Aspect.isConjunction(10.0, 11.0),
    Aspect.doesAspect(Body.mars, 10.0, 100.0),
  ]);
  _use([
    RashiAspect.doesAspect(1, 7),
    RashiAspect.doesAspect(1, 7, RashiAspectMode.element),
    RashiAspect.doesAspectWithOccupants(1, 7, true),
    RashiAspect.doesAspectWithOccupants(1, 7, true, RashiAspectMode.element),
    RashiAspect.mutual(1, 7, true, true),
    RashiAspect.mutual(1, 7, true, true, RashiAspectMode.conventional),
    RashiAspectMode.quadrant,
    RashiAspectMode.element,
    RashiAspectMode.conventional,
    varga,
  ]);
}

void _shadbalaSurface(Shadbala bala) {
  _use([
    bala.uccaBala,
    bala.saptavargajaBala,
    bala.samaVisamaBala,
    bala.kendradiBala,
    bala.drekkanaBala,
    bala.digBala,
    bala.ayanaBala,
    bala.cheshtaBala,
    bala.drigBala,
    bala.sthanaBala,
    bala.totalVirupas,
    bala.totalRupas,
  ]);
  _use([
    ShadbalaCalc.virupasBetween(10.0, 20.0),
    ShadbalaCalc.uccaBala(Body.sun, 10.0),
    ShadbalaCalc.samaVisamaBala(Body.sun, 1, 1),
    ShadbalaCalc.kendradiBala(1),
    ShadbalaCalc.drekkanaBala(Body.sun, 10.0),
    ShadbalaCalc.digBala(Body.sun, 10.0, 100.0),
  ]);
}

void _jaiminiSurface(Varga varga) {
  _use([
    Jaimini.signsForward(1, 4),
    Jaimini.signsApart(1, 5),
    Jaimini.pada(1, 5),
    Jaimini.arudhaLagna(1, 5),
    Jaimini.upapada(1, 5),
    Jaimini.allPadas(varga),
    Jaimini.argala(varga, targetSign: 1),
    Jaimini.firstStrength(varga),
    Jaimini.firstStrength(varga, knRao: true),
    Jaimini.secondStrength(varga),
    Jaimini.secondStrength(varga, rashiAspectMode: RashiAspectMode.element),
  ]);
}

void _nabhasaSurface(Varga varga) {
  final List<NabhasaYoga> ashraya = NabhasaYogaCalc.ashrayaYogas(varga);
  final List<NabhasaYoga> dala = NabhasaYogaCalc.dalaYogas(varga);
  final List<NabhasaYoga> sankhya = NabhasaYogaCalc.sankhyaYogas(
    occupiedHouseCount: 4,
  );
  final List<NabhasaYoga> akriti = NabhasaYogaCalc.akritiYogas(varga);
  _use([ashraya, dala, sankhya, akriti]);
}

void _panchangaSurface() {
  final Tithi tithi = calcTithi(10.0, 200.0);
  final Karana karana = calcKarana(10.0, 200.0, tithi);
  final Yoga yoga = calcYoga(10.0, 200.0);
  final Vara vara = calcVara(2451545.0);
  final panchanga.Nakshatra nak = calcNakshatra(200.0);
  _use([tithi, karana, yoga, vara, nak]);
  _use(vedangaJyotishaEcliptic(10.0));
}

void _zodiacSurface(EphSnapshot snap) {
  final Ecliptic13 ecliptic13 = buildEcliptic13(snap);
  _use(ecliptic13);
}

// ---------------------------------------------------------------------------

/// Every probe, referenced but never invoked — the compile is the assertion.
const List<Function> _probes = <Function>[
  _validateSurface,
  _optionsSurface,
  _sweFacadeSurface,
  _snapshotSurface,
  _snapshotValueTypes,
  _julianDaySurface,
  _chartSurface,
  _vargaSurface,
  _skyObjectSurface,
  _bodySurface,
  _longitudeSurface,
  _dignitySurface,
  _motionSurface,
  _charaKarakaSurface,
  _avasthaSurface,
  _lajjitaadiTypes,
  _aspectSurface,
  _shadbalaSurface,
  _jaiminiSurface,
  _nabhasaSurface,
  _panchangaSurface,
  _zodiacSurface,
];

void main() {
  test('api-reference.md documents an API that still exists', () {
    // If this file compiles, the documented surface is intact. The assertion
    // only guards against someone emptying the probe list.
    expect(_probes, isNotEmpty);
  });
}
