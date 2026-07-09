// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Julian Day conversion utilities using the Meeus formula.
///
/// Ported from libaditya's generate_test_data tooling.

/// Convert a UTC [DateTime] to Julian Day (UT).
///
/// Uses the Meeus formula (Astronomical Algorithms, Jean Meeus).
double julianDay(DateTime dt) {
  final utc = dt.toUtc();
  final hour =
      utc.hour +
      utc.minute / 60.0 +
      utc.second / 3600.0 +
      utc.millisecond / 3600000.0;
  return _meeus(utc.year, utc.month, utc.day, hour);
}

/// Convert a Julian Day (UT) back to a UTC [DateTime].
///
/// Reverse Meeus algorithm — accurate to the millisecond for dates in the
/// Gregorian calendar (post 15 Oct 1582).
DateTime fromJulianDay(double jd) {
  final z = (jd + 0.5).floor();
  final f = (jd + 0.5) - z;

  int a;
  if (z < 2299161) {
    a = z;
  } else {
    final alpha = ((z - 1867216.25) / 36524.25).floor();
    a = z + 1 + alpha - (alpha ~/ 4);
  }

  final b = a + 1524;
  final c = ((b - 122.1) / 365.25).floor();
  final d = (365.25 * c).floor();
  final e = ((b - d) / 30.6001).floor();

  final day = b - d - (30.6001 * e).floor();
  final month = e < 14 ? e - 1 : e - 13;
  final year = month > 2 ? c - 4716 : c - 4715;

  final totalHours = f * 24.0;
  final hour = totalHours.floor();
  final totalMinutes = (totalHours - hour) * 60.0;
  final minute = totalMinutes.floor();
  final totalSeconds = (totalMinutes - minute) * 60.0;
  final second = totalSeconds.floor();
  final millisecond = ((totalSeconds - second) * 1000.0).round().clamp(0, 999);

  return DateTime.utc(year, month, day, hour, minute, second, millisecond);
}

/// Meeus formula for Julian Day Number.
double _meeus(int year, int month, int day, double hour) {
  var y = year;
  var m = month;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  final a = y ~/ 100;
  final b = 2 - a + a ~/ 4;
  final jd =
      (365.25 * (y + 4716)).floor() +
      (30.6001 * (m + 1)).floor() +
      day +
      hour / 24.0 +
      b -
      1524.5;
  return jd;
}
