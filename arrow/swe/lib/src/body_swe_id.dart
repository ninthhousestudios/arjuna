// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:swisseph_rs/swisseph_rs.dart' as swe;

const _bodySweMap = <Body, swe.Body>{
  Body.sun: swe.Body.sun,
  Body.moon: swe.Body.moon,
  Body.mercury: swe.Body.mercury,
  Body.venus: swe.Body.venus,
  Body.mars: swe.Body.mars,
  Body.jupiter: swe.Body.jupiter,
  Body.saturn: swe.Body.saturn,
  Body.uranus: swe.Body.uranus,
  Body.neptune: swe.Body.neptune,
  Body.pluto: swe.Body.pluto,
  Body.chiron: swe.Body.chiron,
};

swe.Body sweBodyFor(Body body) => _bodySweMap[body]!;
