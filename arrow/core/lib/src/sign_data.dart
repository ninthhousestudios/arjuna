// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

enum Element { fire, earth, air, water }

enum Quality { cardinal, fixed, mutable }

enum Gender { male, female }

class SignData {
  SignData._();

  /// Sign lords (1-12 → Body)
  /// Standard Vedic rulership — Rahu/Ketu don't rule signs
  static const lords = <int, Body>{
    1: Body.mars, // Aries
    2: Body.venus, // Taurus
    3: Body.mercury, // Gemini
    4: Body.moon, // Cancer
    5: Body.sun, // Leo
    6: Body.mercury, // Virgo
    7: Body.venus, // Libra
    8: Body.mars, // Scorpio
    9: Body.jupiter, // Sagittarius
    10: Body.saturn, // Capricorn
    11: Body.saturn, // Aquarius
    12: Body.jupiter, // Pisces
  };

  /// Elements cycle: fire, earth, air, water (repeats 3×)
  static const elements = <int, Element>{
    1: Element.fire,
    2: Element.earth,
    3: Element.air,
    4: Element.water,
    5: Element.fire,
    6: Element.earth,
    7: Element.air,
    8: Element.water,
    9: Element.fire,
    10: Element.earth,
    11: Element.air,
    12: Element.water,
  };

  /// Qualities cycle: cardinal (moveable), fixed, mutable (dual) — repeats 4×
  static const qualities = <int, Quality>{
    1: Quality.cardinal,
    2: Quality.fixed,
    3: Quality.mutable,
    4: Quality.cardinal,
    5: Quality.fixed,
    6: Quality.mutable,
    7: Quality.cardinal,
    8: Quality.fixed,
    9: Quality.mutable,
    10: Quality.cardinal,
    11: Quality.fixed,
    12: Quality.mutable,
  };

  /// Genders: odd signs = male, even signs = female
  static const genders = <int, Gender>{
    1: Gender.male,
    2: Gender.female,
    3: Gender.male,
    4: Gender.female,
    5: Gender.male,
    6: Gender.female,
    7: Gender.male,
    8: Gender.female,
    9: Gender.male,
    10: Gender.female,
    11: Gender.male,
    12: Gender.female,
  };

  /// English sign names (for display/reference)
  static const names = <int, String>{
    1: 'Aries',
    2: 'Taurus',
    3: 'Gemini',
    4: 'Cancer',
    5: 'Leo',
    6: 'Virgo',
    7: 'Libra',
    8: 'Scorpio',
    9: 'Sagittarius',
    10: 'Capricorn',
    11: 'Aquarius',
    12: 'Pisces',
  };

  static Body lord(int sign) => lords[sign]!;
  static Element element(int sign) => elements[sign]!;
  static Quality quality(int sign) => qualities[sign]!;
  static Gender gender(int sign) => genders[sign]!;
  static String name(int sign) => names[sign]!;
}
