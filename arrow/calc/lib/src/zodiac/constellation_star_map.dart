import 'package:arrow_options/arrow_options.dart';

/// First and last boundary stars for each of the 13 ecliptic constellations.
///
/// Ported from libaditya `the_stars.py` lines 113-203. The first star is
/// the easternmost (lowest ecliptic longitude) and the last star is the
/// westernmost (highest longitude) within each constellation.
const constellationStarMap = <ConstellationId, ({Star first, Star last})>{
  ConstellationId.aries: (first: Star.mesarthim, last: Star.botein),
  ConstellationId.taurus: (first: Star.omicronTauri, last: Star.zetaTauri),
  ConstellationId.gemini: (first: Star.oneGeminorum, last: Star.kappaGeminorum),
  ConstellationId.cancer: (first: Star.chiCancri, last: Star.acubens),
  ConstellationId.leo: (first: Star.kappaLeonis, last: Star.denebola),
  ConstellationId.virgo: (first: Star.nuVirginis, last: Star.muVirginis),
  ConstellationId.libra: (first: Star.zubenelgenubi, last: Star.fortyEightLibrae),
  ConstellationId.scorpio: (first: Star.dschubba, last: Star.tauScorpii),
  ConstellationId.ophiuchus: (first: Star.sabik, last: Star.fortyFiveOphiuchi),
  ConstellationId.sagittarius: (first: Star.nash, last: Star.omegaSagittarii),
  ConstellationId.capricorn: (first: Star.dabih, last: Star.denebAlgedi),
  ConstellationId.aquarius: (first: Star.iotaAquarii, last: Star.phiAquarii),
  ConstellationId.pisces: (first: Star.gammaPiscium, last: Star.alrescha),
};
