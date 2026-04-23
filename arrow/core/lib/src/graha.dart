import 'planet.dart';

/// A Vedic graha — one of the nine Vedic planets (Sun through Ketu).
///
/// Extends [Planet] in the inheritance chain: CelestialBody → Planet → Graha → Karaka.
class Graha extends Planet {
  Graha(super.body, super.snapshot, super.config, super.vargaType);

  @override
  String toString() => 'Graha(${body.name})';
}
