import 'package:arrow_core/arrow_core.dart';
import 'package:test/test.dart';

void main() {
  final base = DateTime.utc(2024, 6, 15, 12, 30);

  group('sampleTimes', () {
    test('ExactTime returns empty list', () {
      expect(sampleTimes(base, const ExactTime()), isEmpty);
    });

    test('PeriodTime returns start and end boundaries', () {
      final times = sampleTimes(
        base,
        const PeriodTime(startHour: 6, endHour: 12),
      );
      expect(times, [
        DateTime.utc(2024, 6, 15, 6),
        DateTime.utc(2024, 6, 15, 12),
      ]);
    });

    test('PeriodTime handles day rollover when endHour <= startHour', () {
      final times = sampleTimes(
        base,
        const PeriodTime(startHour: 18, endHour: 0),
      );
      expect(times, [
        DateTime.utc(2024, 6, 15, 18),
        DateTime.utc(2024, 6, 16, 0),
      ]);
    });

    test('UnknownTime default interval samples every 4 hours', () {
      final times = sampleTimes(base, const UnknownTime());
      expect(times, [
        DateTime.utc(2024, 6, 15, 0),
        DateTime.utc(2024, 6, 15, 4),
        DateTime.utc(2024, 6, 15, 8),
        DateTime.utc(2024, 6, 15, 12),
        DateTime.utc(2024, 6, 15, 16),
        DateTime.utc(2024, 6, 15, 20),
        DateTime.utc(2024, 6, 16, 0),
      ]);
    });

    test('UnknownTime custom interval', () {
      final times = sampleTimes(base, const UnknownTime(intervalHours: 6));
      expect(times, [
        DateTime.utc(2024, 6, 15, 0),
        DateTime.utc(2024, 6, 15, 6),
        DateTime.utc(2024, 6, 15, 12),
        DateTime.utc(2024, 6, 15, 18),
        DateTime.utc(2024, 6, 16, 0),
      ]);
    });

    test('uses base time date, ignores time-of-day', () {
      final morning = DateTime.utc(2024, 6, 15, 3, 0);
      final evening = DateTime.utc(2024, 6, 15, 21, 45);
      final p = const PeriodTime(startHour: 6, endHour: 12);
      expect(sampleTimes(morning, p), sampleTimes(evening, p));
    });
  });
}
