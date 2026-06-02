import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

import 'package:arrow_core/src/being_data.dart';

void main() {
  group('BeingData', () {
    test('all 60 beings defined (12 signs × 5 types)', () {
      const types = BeingType.values;
      for (var sign = 1; sign <= 12; sign++) {
        for (final type in types) {
          final being = BeingData.forSign(sign, type);
          expect(being.signNumber, sign);
          expect(being.type, type);
          expect(being.name, isNotEmpty);
        }
      }
    });

    test('specific beings match sunflare data', () {
      expect(BeingData.forSign(1, BeingType.gandharva).name, 'Tumburu');
      expect(BeingData.forSign(1, BeingType.rakshasa).name, 'Heti');
      expect(BeingData.forSign(1, BeingType.rishi).name, 'Pulastya');
      expect(BeingData.forSign(3, BeingType.apsara).name, 'Menaka');
      expect(BeingData.forSign(5, BeingType.gandharva).name, 'Vishvavasu');
      expect(BeingData.forSign(8, BeingType.apsara).name, 'Rambha');
      expect(BeingData.forSign(9, BeingType.apsara).name, 'Urvashi');
      expect(BeingData.forSign(12, BeingType.yaksha).name, 'Senajit');
    });

    test('invalid sign throws', () {
      expect(
        () => BeingData.forSign(0, BeingType.gandharva),
        throwsArgumentError,
      );
      expect(
        () => BeingData.forSign(13, BeingType.gandharva),
        throwsArgumentError,
      );
    });
  });

  group('Hora', () {
    group('odd sign', () {
      test('first half is Sun', () {
        // Odd sign: 0-15 = Sun
        for (final deg in [0.0, 7.5, 14.99]) {
          final hora = _computeHora(deg, true);
          expect(hora, Hora.sun, reason: 'deg=$deg in odd sign');
        }
      });

      test('second half is Moon', () {
        // Odd sign: 15-30 = Moon
        for (final deg in [15.0, 22.5, 29.99]) {
          final hora = _computeHora(deg, true);
          expect(hora, Hora.moon, reason: 'deg=$deg in odd sign');
        }
      });
    });

    group('even sign', () {
      test('first half is Moon', () {
        for (final deg in [0.0, 7.5, 14.99]) {
          final hora = _computeHora(deg, false);
          expect(hora, Hora.moon, reason: 'deg=$deg in even sign');
        }
      });

      test('second half is Sun', () {
        for (final deg in [15.0, 22.5, 29.99]) {
          final hora = _computeHora(deg, false);
          expect(hora, Hora.sun, reason: 'deg=$deg in even sign');
        }
      });
    });
  });

  group('Trimsamsa (BeingType)', () {
    group('odd sign segments', () {
      test('0-5: gandharva', () {
        for (final deg in [0.0, 2.5, 4.99]) {
          expect(_computeTrimsamsa(deg, true), BeingType.gandharva);
        }
      });
      test('5-10: rakshasa', () {
        for (final deg in [5.0, 7.5, 9.99]) {
          expect(_computeTrimsamsa(deg, true), BeingType.rakshasa);
        }
      });
      test('10-18: rishi', () {
        for (final deg in [10.0, 14.0, 17.99]) {
          expect(_computeTrimsamsa(deg, true), BeingType.rishi);
        }
      });
      test('18-25: yaksha', () {
        for (final deg in [18.0, 21.5, 24.99]) {
          expect(_computeTrimsamsa(deg, true), BeingType.yaksha);
        }
      });
      test('25-30: apsara', () {
        for (final deg in [25.0, 27.5, 29.99]) {
          expect(_computeTrimsamsa(deg, true), BeingType.apsara);
        }
      });
    });

    group('even sign segments (reversed)', () {
      test('0-5: apsara', () {
        expect(_computeTrimsamsa(2.5, false), BeingType.apsara);
      });
      test('5-12: yaksha', () {
        expect(_computeTrimsamsa(8.0, false), BeingType.yaksha);
      });
      test('12-20: rishi', () {
        expect(_computeTrimsamsa(16.0, false), BeingType.rishi);
      });
      test('20-25: rakshasa', () {
        expect(_computeTrimsamsa(22.0, false), BeingType.rakshasa);
      });
      test('25-30: gandharva', () {
        expect(_computeTrimsamsa(27.0, false), BeingType.gandharva);
      });
    });

    test('boundary values', () {
      // At exact segment boundaries in odd sign
      expect(_computeTrimsamsa(5.0, true), BeingType.rakshasa);
      expect(_computeTrimsamsa(10.0, true), BeingType.rishi);
      expect(_computeTrimsamsa(18.0, true), BeingType.yaksha);
      expect(_computeTrimsamsa(25.0, true), BeingType.apsara);

      // At exact segment boundaries in even sign
      expect(_computeTrimsamsa(5.0, false), BeingType.yaksha);
      expect(_computeTrimsamsa(12.0, false), BeingType.rishi);
      expect(_computeTrimsamsa(20.0, false), BeingType.rakshasa);
      expect(_computeTrimsamsa(25.0, false), BeingType.gandharva);
    });
  });
}

Hora _computeHora(double degree, bool isOdd) {
  final firstHalf = degree < 15;
  return (firstHalf == isOdd) ? Hora.sun : Hora.moon;
}

BeingType _computeTrimsamsa(double degree, bool isOdd) {
  if (isOdd) {
    if (degree < 5) return BeingType.gandharva;
    if (degree < 10) return BeingType.rakshasa;
    if (degree < 18) return BeingType.rishi;
    if (degree < 25) return BeingType.yaksha;
    return BeingType.apsara;
  } else {
    if (degree < 5) return BeingType.apsara;
    if (degree < 12) return BeingType.yaksha;
    if (degree < 20) return BeingType.rishi;
    if (degree < 25) return BeingType.rakshasa;
    return BeingType.gandharva;
  }
}
