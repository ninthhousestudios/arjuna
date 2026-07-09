// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

import 'varga_deities.dart';

/// Result of a varga calculation: the new longitude and optional deity.
typedef VargaResult = (double longitude, VargaDeity? deity);

int _eclipticSignNum(double eclipticLongitude, int adityaOffset) {
  final idx = ((eclipticLongitude + adityaOffset) % 360) ~/ 30;
  return idx.toInt() + 1;
}

double _eclipticInSign(double eclipticLongitude) => eclipticLongitude % 30;

double _baseLon(int signNum, int adityaOffset) =>
    ((30 * (signNum - 1)) - adityaOffset) % 360;

bool _isOdd(int signNum) => signNum.isOdd;

const _deityVargaByAmsha = <int, VargaType>{
  3: VargaType.drekkana,
  4: VargaType.chaturthamsha,
  7: VargaType.saptamsha,
  9: VargaType.navamsha,
  10: VargaType.dashamsha,
  12: VargaType.dvadashamsha,
  16: VargaType.shodashamsha,
  20: VargaType.vimshamsha,
  24: VargaType.parasharaChaturvimshamsha,
  27: VargaType.bhamsha,
  40: VargaType.khavedamsha,
  60: VargaType.shashtyamsha,
};

VargaDeity? _parivrittiDeity(int amsha, int whichAmsha, int realSign) {
  if (amsha == 2) {
    final isOddPortion = (whichAmsha + 1).isOdd;
    if (_isOdd(realSign)) {
      return isOddPortion ? VargaDeity.sun : VargaDeity.moon;
    } else {
      return isOddPortion ? VargaDeity.moon : VargaDeity.sun;
    }
  }
  final type = _deityVargaByAmsha[amsha];
  if (type == null) return null;
  return lookupDeity(type, whichAmsha, signNum: realSign);
}

VargaResult parivritti(double lon, int thisAmsha, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realLon = lon + adityaOffset;

  final amshaSize = 30.0 / thisAmsha;
  final position = realLon / amshaSize;
  final amshaElapsed = position.floor();
  final currentInAmsha = position % 1;

  final baseLon = 0.0 - adityaOffset;

  final deity = _parivrittiDeity(thisAmsha, amshaElapsed, realSign);

  final newLon = baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
  return (newLon, deity);
}

VargaResult hora(double lon, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  final baseLon = _baseLon(realSign, adityaOffset);
  final oppositeLon = (baseLon + 180) % 360;

  VargaDeity deity;
  double newLon;

  if (_isOdd(realSign) && realInSign < 15) {
    deity = VargaDeity.sun;
    newLon = baseLon + (realInSign / 15) * 30;
  } else if (_isOdd(realSign) && realInSign >= 15) {
    deity = VargaDeity.moon;
    newLon = oppositeLon + ((realInSign - 15) / 15) * 30;
  } else if (!_isOdd(realSign) && realInSign < 15) {
    deity = VargaDeity.moon;
    newLon = baseLon + (realInSign / 15) * 30;
  } else {
    deity = VargaDeity.sun;
    newLon = oppositeLon + ((realInSign - 15) / 15) * 30;
  }

  return (newLon, deity);
}

VargaResult drekkana(double lon, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  final baseLon = _baseLon(realSign, adityaOffset);
  final trineLon = (baseLon + 120) % 360;
  final trineTrineLon = (baseLon + 240) % 360;

  VargaDeity deity;
  double newLon;

  if (realInSign < 10) {
    deity = VargaDeity.narada;
    newLon = baseLon + (realInSign / 10) * 30;
  } else if (realInSign < 20) {
    deity = VargaDeity.agastya;
    newLon = trineLon + ((realInSign - 10) / 10) * 30;
  } else {
    deity = VargaDeity.durvasas;
    newLon = trineTrineLon + ((realInSign - 20) / 10) * 30;
  }

  return (newLon, deity);
}

VargaResult chaturthamsha(double lon, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  final baseLon = _baseLon(realSign, adityaOffset);
  final sq1 = (baseLon + 90) % 360;
  final sq2 = (baseLon + 180) % 360;
  final sq3 = (baseLon + 270) % 360;

  const fourth = 30.0 / 4;

  VargaDeity deity;
  double newLon;

  if (realInSign < fourth) {
    deity = VargaDeity.sanaka;
    newLon = baseLon + (realInSign / fourth) * 30;
  } else if (realInSign < 2 * fourth) {
    deity = VargaDeity.sananda;
    newLon = sq1 + ((realInSign - fourth) / fourth) * 30;
  } else if (realInSign < 3 * fourth) {
    deity = VargaDeity.sanatkumara;
    newLon = sq2 + ((realInSign - 2 * fourth) / fourth) * 30;
  } else {
    deity = VargaDeity.sanatana;
    newLon = sq3 + ((realInSign - 3 * fourth) / fourth) * 30;
  }

  return (newLon, deity);
}

VargaResult dashamsha(
  double lon,
  int adityaOffset, {
  bool evenReversed = false,
}) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  final baseLonOdd = _baseLon(realSign, adityaOffset);
  final evenStart = ((realSign - 1) + 8) % 12;
  final baseLonEven = _baseLon(evenStart + 1, adityaOffset);

  const amshaSize = 30.0 / 10;
  final position = realInSign / amshaSize;
  final amshaElapsed = position.floor();
  final currentInAmsha = position % 1;

  final deity = lookupDeity(
    VargaType.dashamsha,
    amshaElapsed % 10,
    signNum: realSign,
  );

  double baseLon;
  int direction = 1;
  if (_isOdd(realSign)) {
    baseLon = baseLonOdd;
  } else {
    baseLon = baseLonEven;
    if (evenReversed) direction = -1;
  }

  final newLon =
      baseLon + (direction * amshaElapsed * 30) + (currentInAmsha * 30);
  return (newLon, deity);
}

VargaResult dvadashamsha(double lon, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  final baseLon = _baseLon(realSign, adityaOffset);

  const amshaSize = 30.0 / 12;
  final position = realInSign / amshaSize;
  final amshaElapsed = position.floor();
  final currentInAmsha = position % 1;

  final deity = lookupDeity(
    VargaType.dvadashamsha,
    amshaElapsed % 4,
    signNum: realSign,
  );

  final newLon = baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
  return (newLon, deity);
}

VargaResult shodashamsha(double lon, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  final baseLonMoveable = _baseLon(1, adityaOffset);
  final baseLonFixed = _baseLon(5, adityaOffset);
  final baseLonDual = _baseLon(9, adityaOffset);

  const amshaSize = 30.0 / 16;
  final position = realInSign / amshaSize;
  final amshaElapsed = position.floor();
  final currentInAmsha = position % 1;

  double baseLon;
  final mod = (realSign - 1) % 3;
  if (mod == 0) {
    baseLon = baseLonMoveable;
  } else if (mod == 1) {
    baseLon = baseLonFixed;
  } else {
    baseLon = baseLonDual;
  }

  final deity = lookupDeity(
    VargaType.shodashamsha,
    amshaElapsed % 4,
    signNum: realSign,
  );

  final newLon = baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
  return (newLon, deity);
}

VargaResult vimshamsha(double lon, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  final baseLonMoveable = _baseLon(1, adityaOffset);
  final baseLonFixed = _baseLon(9, adityaOffset);
  final baseLonDual = _baseLon(5, adityaOffset);

  const amshaSize = 30.0 / 20;
  final position = realInSign / amshaSize;
  final amshaElapsed = position.floor();
  final currentInAmsha = position % 1;

  double baseLon;
  final mod = (realSign - 1) % 3;
  if (mod == 0) {
    baseLon = baseLonMoveable;
  } else if (mod == 1) {
    baseLon = baseLonFixed;
  } else {
    baseLon = baseLonDual;
  }

  final deity = lookupDeity(
    VargaType.vimshamsha,
    amshaElapsed,
    signNum: realSign,
  );

  final newLon = baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
  return (newLon, deity);
}

VargaResult siddhamsha(double lon, int adityaOffset, {bool parashara = false}) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  final baseLonOdd = _baseLon(5, adityaOffset);
  final baseLonEven = _baseLon(4, adityaOffset);

  const amshaSize = 30.0 / 24;
  final position = realInSign / amshaSize;
  final amshaElapsed = position.floor();
  final currentInAmsha = position % 1;

  final deity = lookupDeity(
    VargaType.parasharaChaturvimshamsha,
    amshaElapsed % 12,
    signNum: realSign,
  );

  double newLon;
  if (_isOdd(realSign)) {
    newLon = baseLonOdd + (amshaElapsed * 30) + (currentInAmsha * 30);
  } else {
    final direction = parashara ? 1 : -1;
    newLon =
        baseLonEven + (direction * amshaElapsed * 30) + (currentInAmsha * 30);
  }

  return (newLon, deity);
}

VargaResult bhamsha(double lon, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  final element = ((realSign - 1) % 4);
  final startSign = switch (element) {
    0 => 1,
    1 => 4,
    2 => 7,
    _ => 10,
  };

  final baseLon = _baseLon(startSign, adityaOffset);

  const amshaSize = 30.0 / 27;
  final position = realInSign / amshaSize;
  final amshaElapsed = position.floor();
  final currentInAmsha = position % 1;

  final deity = lookupDeity(VargaType.bhamsha, amshaElapsed, signNum: realSign);

  final newLon = baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
  return (newLon, deity);
}

VargaResult khavedamsha(double lon, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  final baseLon = _isOdd(realSign)
      ? _baseLon(1, adityaOffset)
      : _baseLon(7, adityaOffset);

  const amshaSize = 30.0 / 40;
  final position = realInSign / amshaSize;
  final amshaElapsed = position.floor();
  final currentInAmsha = position % 1;

  final deity = lookupDeity(
    VargaType.khavedamsha,
    amshaElapsed % 12,
    signNum: realSign,
  );

  final newLon = baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
  return (newLon, deity);
}

VargaResult akshavedamsha(double lon, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  final mod = (realSign - 1) % 3;
  final startSign = switch (mod) {
    0 => 1,
    1 => 5,
    _ => 9,
  };

  final baseLon = _baseLon(startSign, adityaOffset);

  const amshaSize = 30.0 / 45;
  final position = realInSign / amshaSize;
  final amshaElapsed = position.floor();
  final currentInAmsha = position % 1;

  final deity = lookupDeity(
    VargaType.akshavedamsha,
    amshaElapsed % 3,
    signNum: realSign,
  );

  final newLon = baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
  return (newLon, deity);
}

VargaResult saptamsha(double lon, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  const amshaSize = 30.0 / 7;
  final position = realInSign / amshaSize;
  final amshaElapsed = position.floor();
  final currentInAmsha = position % 1;

  final startSign = _isOdd(realSign) ? realSign : ((realSign - 1 + 6) % 12) + 1;

  final baseLon = _baseLon(startSign, adityaOffset);

  final deity = lookupDeity(
    VargaType.saptamsha,
    amshaElapsed,
    signNum: realSign,
  );

  final newLon = baseLon + (amshaElapsed * 30) + (currentInAmsha * 30);
  return (newLon, deity);
}

VargaResult trimsamsha(double lon, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  const oddTable = [(5.0, 1), (10.0, 11), (18.0, 9), (25.0, 3), (30.0, 2)];

  const evenTable = [(5.0, 2), (12.0, 3), (20.0, 9), (25.0, 11), (30.0, 1)];

  final table = _isOdd(realSign) ? oddTable : evenTable;

  double prevEnd = 0.0;
  int targetSign = 1;
  double portionSize = 5.0;

  for (final (endDeg, lordSign) in table) {
    if (realInSign < endDeg) {
      targetSign = lordSign;
      portionSize = endDeg - prevEnd;
      break;
    }
    prevEnd = endDeg;
  }

  final posInPortion = (realInSign - prevEnd) / portionSize;
  final baseLon = _baseLon(targetSign, adityaOffset);
  final newLon = baseLon + posInPortion * 30;

  return (newLon, null);
}

VargaResult shashtyamsha(double lon, int adityaOffset) {
  final realSign = _eclipticSignNum(lon, adityaOffset);
  final realInSign = _eclipticInSign(lon);

  final calc = (realInSign * 2).floor();
  final remainder = calc % 12;
  final fromAmsha = remainder + 1;
  final targetSign = ((realSign - 1) + (fromAmsha - 1)) % 12 + 1;

  final baseLon = _baseLon(targetSign, adityaOffset);

  const amshaSize = 30.0 / 60;
  final position = realInSign / amshaSize;
  final amshaElapsed = position.floor();
  final currentInAmsha = position % 1;

  final deity = lookupDeity(
    VargaType.shashtyamsha,
    amshaElapsed,
    signNum: realSign,
  );

  final newLon = baseLon + (currentInAmsha * 30);
  return (newLon, deity);
}
