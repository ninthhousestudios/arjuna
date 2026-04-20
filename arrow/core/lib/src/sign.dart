import 'package:arrow_options/arrow_options.dart';

import 'cusp.dart';
import 'planet.dart';
import 'sign_data.dart';

/// A sign in the context of a chart — knows which planets and cusps occupy it.
class Sign {
  /// Sign number (1-12).
  final int number;

  final List<Planet> _planets;
  final List<Cusp> _cusps;

  Sign(this.number, this._planets, this._cusps);

  Body get lord => SignData.lord(number);
  Element get element => SignData.element(number);
  Quality get quality => SignData.quality(number);
  Gender get gender => SignData.gender(number);
  String get name => SignData.name(number);

  /// Planets occupying this sign.
  List<Planet> get planets => List.unmodifiable(_planets);

  /// House cusps falling in this sign.
  List<Cusp> get cusps => List.unmodifiable(_cusps);

  @override
  String toString() => 'Sign($number, $name)';
}
