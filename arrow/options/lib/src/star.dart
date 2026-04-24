/// Fixed stars supported by Arrow.
///
/// Each entry carries its SWE lookup name (passed directly to
/// `fixstar2Ut`), a human-readable label, an optional visual magnitude,
/// and an optional nakshatra number (1-27) if the star is a junction
/// star (yogatara) for that nakshatra.
enum Star {
  // ── Nakshatra junction stars (yogatara) ──────────────────────────

  sheratan(
    sweName: ',betAri',
    label: 'Sheratan',
    traditionalMag: 2.64,
    nakshatra: 1,
  ),
  fortyOneArietis(
    sweName: ',41Ari',
    label: '41 Arietis',
    traditionalMag: 3.63,
    nakshatra: 2,
  ),
  alcyone(
    sweName: 'Alcyone',
    label: 'Alcyone',
    traditionalMag: 2.87,
    nakshatra: 3,
  ),
  aldebaran(
    sweName: 'Aldebaran',
    label: 'Aldebaran',
    traditionalMag: 0.87,
    nakshatra: 4,
  ),
  meissa(
    sweName: ',lamOri',
    label: 'Meissa',
    traditionalMag: 3.39,
    nakshatra: 5,
  ),
  betelgeuse(
    sweName: 'Betelgeuse',
    label: 'Betelgeuse',
    traditionalMag: 0.42,
    nakshatra: 6,
  ),
  pollux(
    sweName: 'Pollux',
    label: 'Pollux',
    traditionalMag: 1.14,
    nakshatra: 7,
  ),
  asellus(
    sweName: ',delCnc',
    label: 'Asellus Australis',
    traditionalMag: 3.94,
    nakshatra: 8,
  ),
  epsilonHydrae(
    sweName: ',epsHya',
    label: 'Epsilon Hydrae',
    traditionalMag: 3.38,
    nakshatra: 9,
  ),
  regulus(
    sweName: 'Regulus',
    label: 'Regulus',
    traditionalMag: 1.36,
    nakshatra: 10,
  ),
  zosma(
    sweName: ',delLeo',
    label: 'Zosma',
    traditionalMag: 2.56,
    nakshatra: 11,
  ),
  denebola(
    sweName: 'Denebola',
    label: 'Denebola',
    traditionalMag: 2.14,
    nakshatra: 12,
  ),
  algorab(
    sweName: ',delCrv',
    label: 'Algorab',
    traditionalMag: 2.95,
    nakshatra: 13,
  ),
  spica(
    sweName: 'Spica',
    label: 'Spica',
    traditionalMag: 1.04,
    nakshatra: 14,
  ),
  arcturus(
    sweName: 'Arcturus',
    label: 'Arcturus',
    traditionalMag: -0.05,
    nakshatra: 15,
  ),
  zubenelgenubi(
    sweName: ',alf02Lib',
    label: 'Zubenelgenubi',
    traditionalMag: 2.75,
    nakshatra: 16,
  ),
  dschubba(
    sweName: ',delSco',
    label: 'Dschubba',
    traditionalMag: 2.29,
    nakshatra: 17,
  ),
  antares(
    sweName: 'Antares',
    label: 'Antares',
    traditionalMag: 1.06,
    nakshatra: 18,
  ),
  shaula(
    sweName: ',lamSco',
    label: 'Shaula',
    traditionalMag: 1.62,
    nakshatra: 19,
  ),
  kausMedia(
    sweName: ',delSgr',
    label: 'Kaus Media',
    traditionalMag: 2.72,
    nakshatra: 20,
  ),
  nunki(
    sweName: ',sigSgr',
    label: 'Nunki',
    traditionalMag: 2.05,
    nakshatra: 21,
  ),
  altair(
    sweName: 'Altair',
    label: 'Altair',
    traditionalMag: 0.76,
    nakshatra: 22,
  ),
  rotanev(
    sweName: ',betDel',
    label: 'Rotanev',
    traditionalMag: 3.63,
    nakshatra: 23,
  ),
  lambdaAquarii(
    sweName: ',lamAqr',
    label: 'Lambda Aquarii',
    traditionalMag: 3.73,
    nakshatra: 24,
  ),
  markab(
    sweName: 'Markab',
    label: 'Markab',
    traditionalMag: 2.49,
    nakshatra: 25,
  ),
  algenib(
    sweName: 'Algenib',
    label: 'Algenib',
    traditionalMag: 2.83,
    nakshatra: 26,
  ),
  zetaPiscium(
    sweName: ',zetPsc',
    label: 'Zeta Piscium',
    traditionalMag: 5.24,
    nakshatra: 27,
  ),

  // ── Bright / navigational stars ──────────────────────────────────

  sirius(sweName: 'Sirius', label: 'Sirius', traditionalMag: -1.46),
  canopus(sweName: 'Canopus', label: 'Canopus', traditionalMag: -0.72),
  rigel(sweName: 'Rigel', label: 'Rigel', traditionalMag: 0.18),
  procyon(sweName: 'Procyon', label: 'Procyon', traditionalMag: 0.34),
  achernar(sweName: 'Achernar', label: 'Achernar', traditionalMag: 0.46),
  capella(sweName: 'Capella', label: 'Capella', traditionalMag: 0.08),
  vega(sweName: 'Vega', label: 'Vega', traditionalMag: 0.03),
  rigilKentaurus(
    sweName: ',alfCen',
    label: 'Rigil Kentaurus',
    traditionalMag: -0.01,
  ),
  castor(sweName: 'Castor', label: 'Castor', traditionalMag: 1.58),
  fomalhaut(
    sweName: 'Fomalhaut',
    label: 'Fomalhaut',
    traditionalMag: 1.16,
  ),
  deneb(sweName: 'Deneb', label: 'Deneb', traditionalMag: 1.25),
  mimosa(sweName: ',betCru', label: 'Mimosa', traditionalMag: 1.25),
  acrux(sweName: ',alfCru', label: 'Acrux', traditionalMag: 0.77),
  hamal(sweName: 'Hamal', label: 'Hamal', traditionalMag: 2.01),
  polaris(sweName: 'Polaris', label: 'Polaris', traditionalMag: 1.98),
  bellatrix(
    sweName: 'Bellatrix',
    label: 'Bellatrix',
    traditionalMag: 1.64,
  ),
  elNath(sweName: 'El Nath', label: 'El Nath', traditionalMag: 1.65),
  alnilam(sweName: 'Alnilam', label: 'Alnilam', traditionalMag: 1.69),
  alnitak(sweName: ',zetOri', label: 'Alnitak', traditionalMag: 1.74),
  mintaka(sweName: ',delOri', label: 'Mintaka', traditionalMag: 2.25),
  alhena(sweName: ',gamGem', label: 'Alhena', traditionalMag: 1.93),
  alphard(sweName: 'Alphard', label: 'Alphard', traditionalMag: 1.99),
  rasalhague(
    sweName: 'Rasalhague',
    label: 'Rasalhague',
    traditionalMag: 2.08,
  ),
  sabik(sweName: ',etaOph', label: 'Sabik', traditionalMag: 2.43),
  zubeneschamali(
    sweName: ',betLib',
    label: 'Zubeneschamali',
    traditionalMag: 2.61,
  ),

  // ── 13-constellation boundary stars ──────────────────────────────

  mesarthim(sweName: ',gamAri', label: 'Mesarthim', traditionalMag: 3.86),
  botein(sweName: ',delAri', label: 'Botein', traditionalMag: 4.35),
  omicronTauri(
    sweName: ',omiTau',
    label: 'Omicron Tauri',
    traditionalMag: 3.60,
  ),
  zetaTauri(sweName: ',zetTau', label: 'Zeta Tauri', traditionalMag: 2.97),
  oneGeminorum(sweName: ',1Gem', label: '1 Geminorum', traditionalMag: 4.16),
  kappaGeminorum(
    sweName: ',kapGem',
    label: 'Kappa Geminorum',
    traditionalMag: 3.57,
  ),
  chiCancri(sweName: ',chiCnc', label: 'Chi Cancri', traditionalMag: 5.14),
  acubens(sweName: ',alfCnc', label: 'Acubens', traditionalMag: 4.25),
  kappaLeonis(
    sweName: ',kapLeo',
    label: 'Kappa Leonis',
    traditionalMag: 4.46,
  ),
  nuVirginis(sweName: ',nu.Vir', label: 'Nu Virginis', traditionalMag: 4.03),
  muVirginis(
    sweName: ',mu.Vir',
    label: 'Rijl al Awwa',
    traditionalMag: 3.87,
  ),
  fortyEightLibrae(
    sweName: ',48Lib',
    label: '48 Librae',
    traditionalMag: 4.87,
  ),
  tauScorpii(
    sweName: ',tauSco',
    label: 'Tau Scorpii',
    traditionalMag: 2.82,
  ),
  fortyFiveOphiuchi(
    sweName: ',45Oph',
    label: '45 Ophiuchi',
    traditionalMag: 4.29,
  ),
  nash(sweName: ',gam02Sgr', label: 'Nash', traditionalMag: 2.98),
  omegaSagittarii(
    sweName: ',omeSgr',
    label: 'Omega Sagittarii',
    traditionalMag: 4.70,
  ),
  dabih(sweName: ',betCap', label: 'Dabih', traditionalMag: 3.05),
  denebAlgedi(
    sweName: ',delCap',
    label: 'Deneb Algedi',
    traditionalMag: 2.85,
  ),
  iotaAquarii(
    sweName: ',iotAqr',
    label: 'Iota Aquarii',
    traditionalMag: 4.27,
  ),
  phiAquarii(
    sweName: ',phiAqr',
    label: 'Phi Aquarii',
    traditionalMag: 4.22,
  ),
  gammaPiscium(
    sweName: ',gamPsc',
    label: 'Gamma Piscium',
    traditionalMag: 3.69,
  ),
  alrescha(sweName: ',alfPsc', label: 'Alrescha', traditionalMag: 3.82),

  // ── Deep-sky / special ───────────────────────────────────────────

  galacticCenter(
    sweName: ',SgrA*',
    label: 'Galactic Center',
    traditionalMag: null,
  ),
  ;

  final String sweName;
  final String label;
  final double? traditionalMag;
  final int? nakshatra;

  const Star({
    required this.sweName,
    required this.label,
    this.traditionalMag,
    this.nakshatra,
  });

  /// Junction stars only — the 27 yogatara, one per nakshatra.
  static List<Star> get junctionStars =>
      values.where((s) => s.nakshatra != null).toList();
}
