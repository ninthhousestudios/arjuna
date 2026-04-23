import 'package:arrow_core/src/varga_deities.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  group('lookupDeity D2 (hora)', () {
    test('odd sign: index 0 = Sun, index 1 = Moon', () {
      expect(lookupDeity(VargaType.hora, 0, signNum: 1), VargaDeity.sun);
      expect(lookupDeity(VargaType.hora, 1, signNum: 1), VargaDeity.moon);
    });

    test('even sign: index 0 = Moon, index 1 = Sun', () {
      expect(lookupDeity(VargaType.hora, 0, signNum: 2), VargaDeity.moon);
      expect(lookupDeity(VargaType.hora, 1, signNum: 2), VargaDeity.sun);
    });

    test('wraps modulo 2', () {
      expect(lookupDeity(VargaType.hora, 2, signNum: 1), VargaDeity.sun);
      expect(lookupDeity(VargaType.hora, 3, signNum: 1), VargaDeity.moon);
    });

    test('all 12 signs follow odd/even parity', () {
      for (var sign = 1; sign <= 12; sign++) {
        final d0 = lookupDeity(VargaType.hora, 0, signNum: sign);
        if (sign.isOdd) {
          expect(d0, VargaDeity.sun, reason: 'sign $sign idx 0');
        } else {
          expect(d0, VargaDeity.moon, reason: 'sign $sign idx 0');
        }
      }
    });
  });

  group('lookupDeity D3 (drekkana)', () {
    test('cycles through 3 deities', () {
      expect(lookupDeity(VargaType.drekkana, 0), VargaDeity.narada);
      expect(lookupDeity(VargaType.drekkana, 1), VargaDeity.agastya);
      expect(lookupDeity(VargaType.drekkana, 2), VargaDeity.durvasas);
      expect(lookupDeity(VargaType.drekkana, 3), VargaDeity.narada);
    });
  });

  group('lookupDeity D7 (saptamsha)', () {
    test('odd sign uses forward table', () {
      expect(lookupDeity(VargaType.saptamsha, 0, signNum: 1), VargaDeity.kshara);
      expect(
          lookupDeity(VargaType.saptamsha, 6, signNum: 3), VargaDeity.shuddhaJala);
    });

    test('even sign uses reversed table', () {
      expect(
          lookupDeity(VargaType.saptamsha, 0, signNum: 2), VargaDeity.shuddhaJala);
      expect(lookupDeity(VargaType.saptamsha, 6, signNum: 4), VargaDeity.kshara);
    });

    test('odd and even sign index 0 are opposites', () {
      final odd0 = lookupDeity(VargaType.saptamsha, 0, signNum: 1);
      final even0 = lookupDeity(VargaType.saptamsha, 0, signNum: 2);
      final odd6 = lookupDeity(VargaType.saptamsha, 6, signNum: 1);
      expect(even0, odd6);
      expect(odd0, isNot(even0));
    });
  });

  group('lookupDeity D9 (navamsha)', () {
    test('cycles through 3 deities', () {
      expect(lookupDeity(VargaType.navamsha, 0), VargaDeity.deva);
      expect(lookupDeity(VargaType.navamsha, 1), VargaDeity.nri);
      expect(lookupDeity(VargaType.navamsha, 2), VargaDeity.rakshasa);
      expect(lookupDeity(VargaType.navamsha, 3), VargaDeity.deva);
    });
  });

  group('lookupDeity D10 (dashamsha)', () {
    test('even sign reversal', () {
      final even0 = lookupDeity(VargaType.dashamsha, 0, signNum: 2);
      final odd9 = lookupDeity(VargaType.dashamsha, 9, signNum: 1);
      expect(even0, odd9, reason: 'even idx 0 = odd idx 9 (reversed)');
    });
  });

  group('lookupDeity D20 (vimshamsha)', () {
    test('odd sign uses _d20Odd table', () {
      expect(lookupDeity(VargaType.vimshamsha, 0, signNum: 1), VargaDeity.kali);
    });

    test('even sign uses _d20Even table', () {
      expect(lookupDeity(VargaType.vimshamsha, 0, signNum: 2), VargaDeity.daya);
    });

    test('covers all 20 entries without error', () {
      for (var i = 0; i < 20; i++) {
        expect(lookupDeity(VargaType.vimshamsha, i, signNum: 1), isNotNull,
            reason: 'odd sign index $i');
        expect(lookupDeity(VargaType.vimshamsha, i, signNum: 2), isNotNull,
            reason: 'even sign index $i');
      }
    });
  });

  group('lookupDeity D45 (akshavedamsha)', () {
    test('moveable sign (Aries=1)', () {
      expect(lookupDeity(VargaType.akshavedamsha, 0, signNum: 1),
          VargaDeity.vidhi);
    });

    test('fixed sign (Taurus=2)', () {
      expect(lookupDeity(VargaType.akshavedamsha, 0, signNum: 2),
          VargaDeity.isha);
    });

    test('dual sign (Gemini=3)', () {
      expect(lookupDeity(VargaType.akshavedamsha, 0, signNum: 3),
          VargaDeity.vishnu);
    });

    test('all 12 signs produce valid modality', () {
      for (var sign = 1; sign <= 12; sign++) {
        for (var i = 0; i < 3; i++) {
          expect(lookupDeity(VargaType.akshavedamsha, i, signNum: sign),
              isNotNull,
              reason: 'sign $sign index $i');
        }
      }
    });
  });

  group('lookupDeity D60 (shashtyamsha)', () {
    test('even sign reversal', () {
      final even0 = lookupDeity(VargaType.shashtyamsha, 0, signNum: 2);
      final odd59 = lookupDeity(VargaType.shashtyamsha, 59, signNum: 1);
      expect(even0, odd59, reason: 'even idx 0 = odd idx 59 (reversed)');
    });

    test('covers all 60 entries', () {
      for (var i = 0; i < 60; i++) {
        expect(lookupDeity(VargaType.shashtyamsha, i, signNum: 1), isNotNull,
            reason: 'odd sign index $i');
        expect(lookupDeity(VargaType.shashtyamsha, i, signNum: 2), isNotNull,
            reason: 'even sign index $i');
      }
    });
  });

  group('lookupDeity — unknown amsha returns null', () {
    test('rashi (amsha 1) returns null', () {
      expect(lookupDeity(VargaType.rashi, 0), isNull);
    });
  });

  group('lookupDeity — exhaustive parity for all reversible vargas', () {
    final reversibleTypes = {
      VargaType.saptamsha: 7,
      VargaType.dashamsha: 10,
      VargaType.shodashamsha: 4,
      VargaType.parasharaChaturvimshamsha: 12,
      VargaType.bhamsha: 27,
      VargaType.shashtyamsha: 60,
    };

    for (final entry in reversibleTypes.entries) {
      final type = entry.key;
      final size = entry.value;

      test('${type.name}: odd sign[i] == even sign[${size - 1} - i]', () {
        for (var i = 0; i < size; i++) {
          final odd = lookupDeity(type, i, signNum: 1);
          final even = lookupDeity(type, size - 1 - i, signNum: 2);
          expect(odd, even,
              reason: '${type.name} odd[$i] vs even[${size - 1 - i}]');
        }
      });
    }
  });
}
