/// Ayanamsa systems for sidereal calculations.
///
/// Standard codes (0–96) map to Swiss Ephemeris sid modes (SE_SIDM_*).
/// Codes 97+ are libaditya custom ayanamsas.
///
/// SWE user-defined ayanamsa (code 255) is not exposed here; it requires
/// `t0` and `ayanT0` parameters that `SweConfig` does not currently carry.
enum Ayanamsa {
  tropical(sweCode: -1, label: 'Tropical'),

  // --- Standard SWE ayanamsas (SE_SIDM_*) ordered by sweCode ---
  fagan(sweCode: 0, label: 'Fagan/Bradley'),
  lahiri(sweCode: 1, label: 'Lahiri'),
  deLuce(sweCode: 2, label: 'De Luce'),
  raman(sweCode: 3, label: 'Raman'),
  ushashashi(sweCode: 4, label: 'Usha/Shashi'),
  krishnamurti(sweCode: 5, label: 'Krishnamurti'),
  djwhalKhul(sweCode: 6, label: 'Djwhal Khul'),
  yukteswar(sweCode: 7, label: 'Yukteshwar'),
  jnBhasin(sweCode: 8, label: 'JN Bhasin'),
  babylKugler1(sweCode: 9, label: 'Babylonian/Kugler 1'),
  babylKugler2(sweCode: 10, label: 'Babylonian/Kugler 2'),
  babylKugler3(sweCode: 11, label: 'Babylonian/Kugler 3'),
  babylHuber(sweCode: 12, label: 'Babylonian/Huber'),
  babylEtaPsc(sweCode: 13, label: 'Babylonian/Eta Psc'),
  aldebaran15Tau(sweCode: 14, label: 'Aldebaran 15 Tau'),
  hipparchus(sweCode: 15, label: 'Hipparchos'),
  sassanian(sweCode: 16, label: 'Sassanian'),
  galcent0Sag(sweCode: 17, label: 'Galactic Center 0 Sag'),
  j2000(sweCode: 18, label: 'J2000'),
  j1900(sweCode: 19, label: 'J1900'),
  b1950(sweCode: 20, label: 'B1950'),
  suryaSiddhanta(sweCode: 21, label: 'Surya Siddhanta'),
  suryaSiddhantaMeanSun(sweCode: 22, label: 'Surya Siddhanta (mean Sun)'),
  aryabhata(sweCode: 23, label: 'Aryabhata'),
  aryabhataMeanSun(sweCode: 24, label: 'Aryabhata (mean Sun)'),
  ssRevati(sweCode: 25, label: 'SS Revati'),
  ssCitra(sweCode: 26, label: 'SS Citra'),
  trueCitra(sweCode: 27, label: 'True Citra'),
  trueRevati(sweCode: 28, label: 'True Revati'),
  truePushya(sweCode: 29, label: 'True Pushya'),
  galcentRgilbrand(sweCode: 30, label: 'Galactic Center (Gil Brand)'),
  galequIau1958(sweCode: 31, label: 'Galactic Equator IAU 1958'),
  galequTrue(sweCode: 32, label: 'Galactic Equator (true)'),
  galequMula(sweCode: 33, label: 'Galactic Equator Mula'),
  galalignMardyks(sweCode: 34, label: 'Galactic Alignment (Mardyks)'),
  trueMula(sweCode: 35, label: 'True Mula'),
  galCenterMula(sweCode: 36, label: 'GC Mula (Wilhelm)'),
  aryabhata522(sweCode: 37, label: 'Aryabhata 522'),
  babylBritton(sweCode: 38, label: 'Babylonian/Britton'),
  trueSheoran(sweCode: 39, label: 'True Sheoran'),
  galcentCochrane(sweCode: 40, label: 'Galactic Center (Cochrane)'),
  galequFiorenza(sweCode: 41, label: 'Galactic Equator (Fiorenza)'),
  valensMoon(sweCode: 42, label: 'Vettius Valens Moon'),
  lahiri1940(sweCode: 43, label: 'Lahiri 1940'),
  lahiriVp285(sweCode: 44, label: 'Lahiri VP285'),
  krishnamurtiVp291(sweCode: 45, label: 'Krishnamurti VP291'),
  lahiriIcrc(sweCode: 46, label: 'Lahiri ICRC'),

  // --- Custom libaditya ayanamsas (codes 97+) ---
  trueSidereal(sweCode: 97, label: 'True Sidereal'),
  dhruva(sweCode: 98, label: 'Dhruva GC mid-Mula Equatorial'),
  eclipticVedangaJyotisha(sweCode: 99, label: 'Ecliptic Vedanga Jyotisha'),
  equatorialVedangaJyotisha(sweCode: 100, label: 'Equatorial Vedanga Jyotisha'),
  equal28Nakshatras(sweCode: 101, label: '28 Equal Nakshatras');

  final int sweCode;
  final String label;
  const Ayanamsa({required this.sweCode, required this.label});

  /// Whether this is a standard SWE ayanamsa (vs custom libaditya one).
  bool get isStandard => sweCode >= 0 && sweCode <= 96;

  /// Whether this represents no ayanamsa (tropical).
  bool get isTropical => this == tropical;
}
