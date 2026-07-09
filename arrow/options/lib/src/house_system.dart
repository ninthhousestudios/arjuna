// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// House systems supported by Swiss Ephemeris.
enum HouseSystem {
  placidus(sweChar: 'P', label: 'Placidus'),
  koch(sweChar: 'K', label: 'Koch'),
  porphyrius(sweChar: 'O', label: 'Porphyrius'),
  regiomontanus(sweChar: 'R', label: 'Regiomontanus'),
  campanus(sweChar: 'C', label: 'Campanus'),
  equalAsc(sweChar: 'A', label: 'Equal (Asc)'),
  vehlowEqual(sweChar: 'V', label: 'Vehlow Equal'),
  wholeSigns(sweChar: 'W', label: 'Whole Sign'),
  meridian(sweChar: 'X', label: 'Meridian'),
  horizon(sweChar: 'H', label: 'Horizon'),
  topocentric(sweChar: 'T', label: 'Polich/Page'),
  alcabitus(sweChar: 'B', label: 'Alcabitus'),
  morinus(sweChar: 'M', label: 'Morinus'),
  krusinski(sweChar: 'U', label: 'Krusinski'),
  equalAries(sweChar: 'E', label: 'Equal (0 Aries)');

  final String sweChar;
  final String label;
  const HouseSystem({required this.sweChar, required this.label});
}
