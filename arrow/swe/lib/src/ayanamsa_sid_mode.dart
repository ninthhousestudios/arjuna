// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:swisseph_rs/swisseph_rs.dart' as swe;

final _byCode = {for (final m in swe.SiderealMode.values) m.value: m};

swe.SiderealMode siderealModeFor(Ayanamsa a) {
  assert(!a.isTropical && a.isStandard);
  return _byCode[a.sweCode]!;
}
