/// Core data model for astrological chart data.
///
/// Copied from charts_dart — the common denominator across chart file formats.
class ChartData {
  String name;
  DateTime dateTime; // Local time
  GeoLocation birthLocation;
  double utcOffsetHours; // Hours east of UTC (e.g. IST = 5.5, EST = -5.0)
  double dstOffsetHours;

  Gender? gender;
  String? notes;

  ChartData({
    required this.name,
    required this.dateTime,
    required this.birthLocation,
    this.utcOffsetHours = 0.0,
    this.dstOffsetHours = 0.0,
    this.gender,
    this.notes,
  });

  /// UTC datetime.
  DateTime get utcDateTime => dateTime.subtract(Duration(
        minutes: ((utcOffsetHours + dstOffsetHours) * 60).round(),
      ));

  /// Decimal hours of the local time (e.g. 14:30 -> 14.5).
  double get decimalHours =>
      dateTime.hour + dateTime.minute / 60.0 + dateTime.second / 3600.0;

  @override
  String toString() =>
      'ChartData($name, ${dateTime.toIso8601String()}, $birthLocation)';
}

enum Gender { male, female, unknown }

class GeoLocation {
  String city;
  String country;
  double latitude; // Positive = north
  double longitude; // Positive = east

  GeoLocation({
    this.city = '',
    this.country = '',
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() {
    final ns = latitude >= 0 ? 'N' : 'S';
    final ew = longitude >= 0 ? 'E' : 'W';
    return '$city, $country '
        '(${latitude.abs().toStringAsFixed(2)}$ns, '
        '${longitude.abs().toStringAsFixed(2)}$ew)';
  }
}
