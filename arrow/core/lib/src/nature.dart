// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

/// Benefic / malefic / neutral classification of a [Body].
///
/// Vedic convention (Parashara). Twelve of the 13 bodies have a **fixed**
/// nature (Sun/Mars/Saturn/Rahu/Ketu malefic; Mercury/Jupiter/Venus
/// benefic; Uranus/Neptune/Pluto neutral). The **Moon is contextual** —
/// benefic in Shukla Paksha (bright half, Sun→Moon forward distance
/// ≤ 180°), malefic in Krishna Paksha (waning half). Ported from libaditya
/// `planets.py:1652`:
///
/// ```python
/// moon_nature = "Benefic" if sun.degrees_apart(moon.lon) <= 180 else "Malefic"
/// ```
///
/// Callers that touch Moon must supply [sunLongitude] + [moonLongitude].
/// For every other body the context parameters are ignored.
enum Nature {
  benefic,
  malefic,
  neutral;

  /// Classify [body]. Pass [sunLongitude] + [moonLongitude] when [body] is
  /// [Body.moon] — they are the only path that makes Moon's nature
  /// observable. For all other bodies the context is ignored.
  ///
  /// Throws [ArgumentError] if Moon is classified without context.
  static Nature of(Body body, {double? sunLongitude, double? moonLongitude}) {
    switch (body) {
      case Body.sun:
      case Body.mars:
      case Body.saturn:
      case Body.rahu:
      case Body.ketu:
        return Nature.malefic;
      case Body.mercury:
      case Body.jupiter:
      case Body.venus:
        return Nature.benefic;
      case Body.moon:
        if (sunLongitude == null || moonLongitude == null) {
          throw ArgumentError(
            'Nature.of(Body.moon) requires sunLongitude + moonLongitude. '
            'Moon is contextual (Shukla→benefic, Krishna→malefic).',
          );
        }
        return ofMoon(sunLongitude: sunLongitude, moonLongitude: moonLongitude);
      case Body.uranus:
      case Body.neptune:
      case Body.pluto:
      case Body.chiron:
        return Nature.neutral;
    }
  }

  /// Contextual Moon nature from the Sun→Moon forward angular distance.
  ///
  /// Distance is `(moonLongitude - sunLongitude) mod 360`, always in
  /// `[0, 360)`. `≤ 180°` is Shukla Paksha (waxing, benefic); `> 180°` is
  /// Krishna Paksha (waning, malefic).
  static Nature ofMoon({
    required double sunLongitude,
    required double moonLongitude,
  }) {
    var d = (moonLongitude - sunLongitude) % 360.0;
    if (d < 0) d += 360.0;
    return d <= 180.0 ? Nature.benefic : Nature.malefic;
  }
}
