import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

import 'package:arrow_core/src/sign_data.dart';

void main() {
  group('SignData', () {
    test('all 12 sign lords defined', () {
      for (var i = 1; i <= 12; i++) {
        expect(SignData.lords.containsKey(i), isTrue);
      }
    });

    test('specific lords', () {
      expect(SignData.lord(1), Body.mars);     // Aries
      expect(SignData.lord(2), Body.venus);    // Taurus
      expect(SignData.lord(4), Body.moon);     // Cancer
      expect(SignData.lord(5), Body.sun);      // Leo
      expect(SignData.lord(9), Body.jupiter);  // Sagittarius
      expect(SignData.lord(10), Body.saturn);  // Capricorn
    });

    test('dual rulerships', () {
      // Mars rules Aries and Scorpio
      expect(SignData.lord(1), Body.mars);
      expect(SignData.lord(8), Body.mars);
      // Jupiter rules Sagittarius and Pisces
      expect(SignData.lord(9), Body.jupiter);
      expect(SignData.lord(12), Body.jupiter);
      // Venus rules Taurus and Libra
      expect(SignData.lord(2), Body.venus);
      expect(SignData.lord(7), Body.venus);
      // Mercury rules Gemini and Virgo
      expect(SignData.lord(3), Body.mercury);
      expect(SignData.lord(6), Body.mercury);
      // Saturn rules Capricorn and Aquarius
      expect(SignData.lord(10), Body.saturn);
      expect(SignData.lord(11), Body.saturn);
    });

    test('element cycle', () {
      expect(SignData.element(1), Element.fire);
      expect(SignData.element(2), Element.earth);
      expect(SignData.element(3), Element.air);
      expect(SignData.element(4), Element.water);
      // Cycle repeats
      expect(SignData.element(5), Element.fire);
      expect(SignData.element(9), Element.fire);
      expect(SignData.element(12), Element.water);
    });

    test('quality cycle', () {
      expect(SignData.quality(1), Quality.cardinal);
      expect(SignData.quality(2), Quality.fixed);
      expect(SignData.quality(3), Quality.mutable);
      expect(SignData.quality(4), Quality.cardinal);
      expect(SignData.quality(10), Quality.cardinal);
      expect(SignData.quality(11), Quality.fixed);
      expect(SignData.quality(12), Quality.mutable);
    });

    test('gender alternates', () {
      expect(SignData.gender(1), Gender.male);
      expect(SignData.gender(2), Gender.female);
      expect(SignData.gender(3), Gender.male);
      expect(SignData.gender(11), Gender.male);
      expect(SignData.gender(12), Gender.female);
    });

    test('sign names', () {
      expect(SignData.name(1), 'Aries');
      expect(SignData.name(7), 'Libra');
      expect(SignData.name(12), 'Pisces');
      expect(SignData.name(5), 'Leo');
    });
  });
}
