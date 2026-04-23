import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

void main() {
  group('julianDay', () {
    test('J2000.0 epoch (2000-01-01 12:00 UTC) = 2451545.0', () {
      final dt = DateTime.utc(2000, 1, 1, 12, 0, 0);
      expect(julianDay(dt), closeTo(2451545.0, 1e-9));
    });

    test('known historical date: 1985-07-04 00:00 UTC', () {
      final dt = DateTime.utc(1985, 7, 4, 0, 0, 0);
      // Expected JD from standard tables: 2446250.5
      expect(julianDay(dt), closeTo(2446250.5, 1e-9));
    });

    test('Unix epoch: 1970-01-01 00:00 UTC', () {
      final dt = DateTime.utc(1970, 1, 1, 0, 0, 0);
      // Expected JD: 2440587.5
      expect(julianDay(dt), closeTo(2440587.5, 1e-9));
    });
  });

  group('fromJulianDay', () {
    test('J2000.0 epoch round-trip', () {
      final dt = fromJulianDay(2451545.0);
      expect(dt.year, 2000);
      expect(dt.month, 1);
      expect(dt.day, 1);
      expect(dt.hour, 12);
      expect(dt.minute, 0);
      expect(dt.isUtc, isTrue);
    });

    test('1985-07-04 round-trip', () {
      final dt = fromJulianDay(2446250.5);
      expect(dt.year, 1985);
      expect(dt.month, 7);
      expect(dt.day, 4);
      expect(dt.hour, 0);
      expect(dt.minute, 0);
      expect(dt.isUtc, isTrue);
    });
  });

  group('round-trip', () {
    test('DateTime -> JD -> DateTime preserves to millisecond', () {
      final original = DateTime.utc(2024, 3, 15, 14, 30, 45, 123);
      final jd = julianDay(original);
      final restored = fromJulianDay(jd);

      expect(restored.year, original.year);
      expect(restored.month, original.month);
      expect(restored.day, original.day);
      expect(restored.hour, original.hour);
      expect(restored.minute, original.minute);
      expect(restored.second, original.second);
      expect(restored.millisecond, closeTo(original.millisecond, 1));
      expect(restored.isUtc, isTrue);
    });

    test('JD -> DateTime -> JD preserves to sub-second precision', () {
      const jd = 2460000.123456;
      final dt = fromJulianDay(jd);
      final restored = julianDay(dt);
      // Millisecond precision is ~1.16e-8 days
      expect(restored, closeTo(jd, 2e-8));
    });

    test('near-midnight millisecond edge case does not produce ms=1000', () {
      // JD for 2024-01-01 23:59:59.9997 — rounding would push ms to 1000.
      final dt = fromJulianDay(2460311.49999997);
      expect(dt.millisecond, lessThanOrEqualTo(999));
      expect(dt.millisecond, greaterThanOrEqualTo(0));
      expect(dt.isUtc, isTrue);
    });
  });
}
