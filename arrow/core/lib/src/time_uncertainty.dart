sealed class TimeUncertainty {
  const TimeUncertainty();
}

class ExactTime extends TimeUncertainty {
  const ExactTime();
}

class PeriodTime extends TimeUncertainty {
  final int startHour;
  final int endHour;

  const PeriodTime({required this.startHour, required this.endHour})
    : assert(startHour >= 0 && startHour <= 23, 'startHour must be 0..23'),
      assert(endHour >= 0 && endHour <= 23, 'endHour must be 0..23');
}

class UnknownTime extends TimeUncertainty {
  final int intervalHours;

  const UnknownTime({this.intervalHours = 4})
    : assert(
        intervalHours >= 1 && intervalHours <= 24,
        'intervalHours must be 1..24',
      );
}

List<DateTime> sampleTimes(DateTime baseTime, TimeUncertainty uncertainty) {
  final y = baseTime.year;
  final m = baseTime.month;
  final d = baseTime.day;

  return switch (uncertainty) {
    ExactTime() => [],
    PeriodTime(:final startHour, :final endHour) => [
      DateTime.utc(y, m, d, startHour),
      DateTime.utc(y, m, d + (endHour <= startHour ? 1 : 0), endHour),
    ],
    UnknownTime(:final intervalHours) => [
      for (var h = 0; h < 24; h += intervalHours) DateTime.utc(y, m, d, h),
      DateTime.utc(y, m, d + 1),
    ],
  };
}
