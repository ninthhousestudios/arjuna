// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Fixed stars supported by Arrow.
///
/// Each entry carries a human-readable label, an optional visual magnitude,
/// and an optional nakshatra number (1-27) if the star is a junction
/// star (yogatara) for that nakshatra.
enum Star {
  // ── Nakshatra junction stars (yogatara) ──────────────────────────

  sheratan(label: 'Sheratan', traditionalMag: 2.64, nakshatra: 1),
  fortyOneArietis(label: '41 Arietis', traditionalMag: 3.63, nakshatra: 2),
  alcyone(label: 'Alcyone', traditionalMag: 2.87, nakshatra: 3),
  aldebaran(label: 'Aldebaran', traditionalMag: 0.87, nakshatra: 4),
  meissa(label: 'Meissa', traditionalMag: 3.39, nakshatra: 5),
  betelgeuse(label: 'Betelgeuse', traditionalMag: 0.42, nakshatra: 6),
  pollux(label: 'Pollux', traditionalMag: 1.14, nakshatra: 7),
  asellus(label: 'Asellus Australis', traditionalMag: 3.94, nakshatra: 8),
  epsilonHydrae(label: 'Epsilon Hydrae', traditionalMag: 3.38, nakshatra: 9),
  regulus(label: 'Regulus', traditionalMag: 1.36, nakshatra: 10),
  zosma(label: 'Zosma', traditionalMag: 2.56, nakshatra: 11),
  denebola(label: 'Denebola', traditionalMag: 2.14, nakshatra: 12),
  algorab(label: 'Algorab', traditionalMag: 2.95, nakshatra: 13),
  spica(label: 'Spica', traditionalMag: 1.04, nakshatra: 14),
  arcturus(label: 'Arcturus', traditionalMag: -0.05, nakshatra: 15),
  zubenelgenubi(label: 'Zubenelgenubi', traditionalMag: 2.75, nakshatra: 16),
  dschubba(label: 'Dschubba', traditionalMag: 2.29, nakshatra: 17),
  antares(label: 'Antares', traditionalMag: 1.06, nakshatra: 18),
  shaula(label: 'Shaula', traditionalMag: 1.62, nakshatra: 19),
  kausMedia(label: 'Kaus Media', traditionalMag: 2.72, nakshatra: 20),
  nunki(label: 'Nunki', traditionalMag: 2.05, nakshatra: 21),
  altair(label: 'Altair', traditionalMag: 0.76, nakshatra: 22),
  rotanev(label: 'Rotanev', traditionalMag: 3.63, nakshatra: 23),
  lambdaAquarii(label: 'Lambda Aquarii', traditionalMag: 3.73, nakshatra: 24),
  markab(label: 'Markab', traditionalMag: 2.49, nakshatra: 25),
  algenib(label: 'Algenib', traditionalMag: 2.83, nakshatra: 26),
  zetaPiscium(label: 'Zeta Piscium', traditionalMag: 5.24, nakshatra: 27),

  // ── Bright / navigational stars ──────────────────────────────────

  sirius(label: 'Sirius', traditionalMag: -1.46),
  canopus(label: 'Canopus', traditionalMag: -0.72),
  rigel(label: 'Rigel', traditionalMag: 0.18),
  procyon(label: 'Procyon', traditionalMag: 0.34),
  achernar(label: 'Achernar', traditionalMag: 0.46),
  capella(label: 'Capella', traditionalMag: 0.08),
  vega(label: 'Vega', traditionalMag: 0.03),
  rigilKentaurus(label: 'Rigil Kentaurus', traditionalMag: -0.01),
  castor(label: 'Castor', traditionalMag: 1.58),
  fomalhaut(label: 'Fomalhaut', traditionalMag: 1.16),
  deneb(label: 'Deneb', traditionalMag: 1.25),
  mimosa(label: 'Mimosa', traditionalMag: 1.25),
  acrux(label: 'Acrux', traditionalMag: 0.77),
  hamal(label: 'Hamal', traditionalMag: 2.01),
  polaris(label: 'Polaris', traditionalMag: 1.98),
  bellatrix(label: 'Bellatrix', traditionalMag: 1.64),
  elNath(label: 'El Nath', traditionalMag: 1.65),
  alnilam(label: 'Alnilam', traditionalMag: 1.69),
  alnitak(label: 'Alnitak', traditionalMag: 1.74),
  mintaka(label: 'Mintaka', traditionalMag: 2.25),
  alhena(label: 'Alhena', traditionalMag: 1.93),
  alphard(label: 'Alphard', traditionalMag: 1.99),
  rasalhague(label: 'Rasalhague', traditionalMag: 2.08),
  sabik(label: 'Sabik', traditionalMag: 2.43),
  zubeneschamali(label: 'Zubeneschamali', traditionalMag: 2.61),

  // ── 13-constellation boundary stars ──────────────────────────────

  mesarthim(label: 'Mesarthim', traditionalMag: 3.86),
  botein(label: 'Botein', traditionalMag: 4.35),
  omicronTauri(label: 'Omicron Tauri', traditionalMag: 3.60),
  zetaTauri(label: 'Zeta Tauri', traditionalMag: 2.97),
  oneGeminorum(label: '1 Geminorum', traditionalMag: 4.16),
  kappaGeminorum(label: 'Kappa Geminorum', traditionalMag: 3.57),
  chiCancri(label: 'Chi Cancri', traditionalMag: 5.14),
  acubens(label: 'Acubens', traditionalMag: 4.25),
  kappaLeonis(label: 'Kappa Leonis', traditionalMag: 4.46),
  nuVirginis(label: 'Nu Virginis', traditionalMag: 4.03),
  muVirginis(label: 'Rijl al Awwa', traditionalMag: 3.87),
  fortyEightLibrae(label: '48 Librae', traditionalMag: 4.87),
  tauScorpii(label: 'Tau Scorpii', traditionalMag: 2.82),
  fortyFiveOphiuchi(label: '45 Ophiuchi', traditionalMag: 4.29),
  nash(label: 'Nash', traditionalMag: 2.98),
  sixtyTwoSagittarii(label: '62 Sagittarii', traditionalMag: 4.58),
  algedi(label: 'Algedi', traditionalMag: 3.58),
  denebAlgedi(label: 'Deneb Algedi', traditionalMag: 2.85),
  iotaAquarii(label: 'Iota Aquarii', traditionalMag: 4.27),
  phiAquarii(label: 'Phi Aquarii', traditionalMag: 4.22),
  gammaPiscium(label: 'Gamma Piscium', traditionalMag: 3.69),
  alrescha(label: 'Alrescha', traditionalMag: 3.82),

  // ── Deep-sky / special ───────────────────────────────────────────

  galacticCenter(label: 'Galactic Center', traditionalMag: null);

  final String label;
  final double? traditionalMag;
  final int? nakshatra;

  const Star({required this.label, this.traditionalMag, this.nakshatra});

  /// Junction stars only — the 27 yogatara, one per nakshatra.
  static List<Star> get junctionStars =>
      values.where((s) => s.nakshatra != null).toList();
}
