// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

/// First and last boundary stars for each of the 13 ecliptic constellations.
///
/// Edge stars follow Chimenti's Midpoint Method, Table 1
/// (`docs/true-sidereal-method.md`). The first star is the one at lowest
/// ecliptic longitude and the last star the one at highest longitude within
/// each constellation. Originally ported from libaditya `the_stars.py`; the
/// Sagittarius-last (62 Sagittarii / HIP 98688) and Capricornus-first
/// (Algedi / α² Cap / HIP 100064) stars were corrected to match the paper.
const constellationStarMap = <ConstellationId, ({Star first, Star last})>{
  ConstellationId.aries: (first: Star.mesarthim, last: Star.botein),
  ConstellationId.taurus: (first: Star.omicronTauri, last: Star.zetaTauri),
  ConstellationId.gemini: (first: Star.oneGeminorum, last: Star.kappaGeminorum),
  ConstellationId.cancer: (first: Star.chiCancri, last: Star.acubens),
  ConstellationId.leo: (first: Star.kappaLeonis, last: Star.denebola),
  ConstellationId.virgo: (first: Star.nuVirginis, last: Star.muVirginis),
  ConstellationId.libra: (
    first: Star.zubenelgenubi,
    last: Star.fortyEightLibrae,
  ),
  ConstellationId.scorpio: (first: Star.dschubba, last: Star.tauScorpii),
  ConstellationId.ophiuchus: (first: Star.sabik, last: Star.fortyFiveOphiuchi),
  ConstellationId.sagittarius: (
    first: Star.nash,
    last: Star.sixtyTwoSagittarii,
  ),
  ConstellationId.capricorn: (first: Star.algedi, last: Star.denebAlgedi),
  ConstellationId.aquarius: (first: Star.iotaAquarii, last: Star.phiAquarii),
  ConstellationId.pisces: (first: Star.gammaPiscium, last: Star.alrescha),
};
