// ignore: unused_import
import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

void main() {
  test('arrow_calc package resolves + depends on core/swe/options', () {
    expect(Body.sun, isNotNull);
    expect(Sign, isNotNull);
    expect(EphSnapshot, isNotNull);
    expect(const ArrowOptions(), isNotNull);
  });
}
