// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_core/arrow_core.dart';

const signGlyphs = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];

const signAbbreviations = [
  'Ari',
  'Tau',
  'Gem',
  'Can',
  'Leo',
  'Vir',
  'Lib',
  'Sco',
  'Sag',
  'Cap',
  'Aqu',
  'Pis',
];

/// Format a [Longitude] as "DD°MM' ♊" (degrees, arcminutes, sign glyph).
String formatLongitude(Longitude lon) {
  final deg = lon.inSignLongitude;
  final d = deg.truncate();
  final m = ((deg - d) * 60).truncate();
  final glyph = signGlyphs[lon.sign - 1];
  return "${d.toString().padLeft(2)}°${m.toString().padLeft(2, '0')}' $glyph";
}

/// Full sign name for a sign number (1-12).
String signName(int sign) => SignData.name(sign);

/// Three-letter sign abbreviation for a sign number (1-12).
String signAbbr(int sign) => signAbbreviations[sign - 1];

/// Sign glyph for a sign number (1-12).
String signGlyph(int sign) => signGlyphs[sign - 1];
