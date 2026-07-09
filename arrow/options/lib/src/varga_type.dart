// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Varga (divisional chart) types.
///
/// Each carries its amsha (division number) and whether it uses the
/// parivritti (regular n-fold) method. Named values replace libaditya's
/// negative-integer convention.
enum VargaType {
  rashi(amsha: 1),
  hora(amsha: 2),
  horaParivritti(amsha: 2, isParivritti: true),
  drekkana(amsha: 3),
  drekkanaParivritti(amsha: 3, isParivritti: true),
  chaturthamsha(amsha: 4),
  chaturthaParivritti(amsha: 4, isParivritti: true),
  panchamsha(amsha: 5, isParivritti: true),
  saptamsha(amsha: 7),
  saptamshaParivritti(amsha: 7, isParivritti: true),
  navamsha(amsha: 9, isParivritti: true),
  dashamsha(amsha: 10),
  dashamshaReversed(amsha: 10),
  dashamshaParivritti(amsha: 10, isParivritti: true),
  dvadashamsha(amsha: 12),
  shodashamsha(amsha: 16),
  shodamshaParivritti(amsha: 16, isParivritti: true),
  vimshamsha(amsha: 20),
  vimshamshaParivritti(amsha: 20, isParivritti: true),
  parasharaChaturvimshamsha(amsha: 24),
  siddhamsha(amsha: 24),
  chaturvimshaParivritti(amsha: 24, isParivritti: true),
  bhamsha(amsha: 27),
  bhamshaParivritti(amsha: 27, isParivritti: true),
  trimsamsha(amsha: 30),
  trimshaParivritti(amsha: 30, isParivritti: true),
  khavedamsha(amsha: 40),
  khavedamshaParivritti(amsha: 40, isParivritti: true),
  akshavedamsha(amsha: 45),
  akshavedamshaParivritti(amsha: 45, isParivritti: true),
  shashtyamsha(amsha: 60),
  shashtyamshaParivritti(amsha: 60, isParivritti: true);

  final int amsha;
  final bool isParivritti;
  const VargaType({required this.amsha, this.isParivritti = false});
}
