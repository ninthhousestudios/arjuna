import 'graha.dart';

/// A karaka — a graha eligible for Jaimini chara karaka assignment.
///
/// Extends [Graha] with stubs for dignity and combustion that will be
/// filled in Issue 8.
class Karaka extends Graha {
  Karaka(super.planet);

  /// In-sign longitude used for chara karaka sorting.
  double get inSignLongitude => longitude.inSignLongitude;

  @override
  String toString() => 'Karaka(${body.name})';
}
