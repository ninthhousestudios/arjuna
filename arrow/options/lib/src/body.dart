/// Celestial bodies supported by Arrow.
enum Body {
  sun(sweId: 0),
  moon(sweId: 1),
  mercury(sweId: 2),
  venus(sweId: 3),
  mars(sweId: 4),
  jupiter(sweId: 5),
  saturn(sweId: 6),
  uranus(sweId: 7),
  neptune(sweId: 8),
  pluto(sweId: 9),
  chiron(sweId: 15),
  rahu(sweId: 11), // SWE TRUE_NODE
  ketu(sweId: -1); // Computed from Rahu, never passed to SWE

  final int sweId;
  const Body({required this.sweId});

  /// The 7 embodied planets (Sun through Saturn) — the karakas.
  static const karakas = [sun, moon, mars, mercury, jupiter, venus, saturn];

  /// The 9 Vedic grahas (7 karakas + nodes).
  static const grahas = [
    sun, moon, mars, mercury, jupiter, venus, saturn, rahu, ketu,
  ];
}
