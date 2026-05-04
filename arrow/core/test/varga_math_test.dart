import 'package:arrow_core/src/varga_deities.dart';
import 'package:arrow_core/src/varga_math.dart';
import 'package:test/test.dart';

void main() {
  const zodiac = 0;
  const aditya = 30;

  group('hora', () {
    test('odd sign first half: Sun deity', () {
      // 10deg in sign 1 (odd), inSign = 10 < 15
      final (lon, deity) = hora(10.0, zodiac);
      expect(deity, VargaDeity.sun);
      expect(lon, closeTo(20.0, 0.001));
    });

    test('odd sign second half: Moon deity, opposite sign', () {
      // 20deg in sign 1 (odd), inSign = 20 >= 15
      final (lon, deity) = hora(20.0, zodiac);
      expect(deity, VargaDeity.moon);
      expect(lon, closeTo(190.0, 0.001));
    });

    test('even sign first half: Moon deity', () {
      // 40deg = sign 2 (even), inSign = 10
      final (_, deity) = hora(40.0, zodiac);
      expect(deity, VargaDeity.moon);
    });

    test('even sign second half: Sun deity', () {
      // 50deg = sign 2 (even), inSign = 20
      final (_, deity) = hora(50.0, zodiac);
      expect(deity, VargaDeity.sun);
    });

    test('boundary at exactly 15deg in sign triggers second half', () {
      final (_, deity) = hora(15.0, zodiac);
      expect(deity, VargaDeity.moon);
    });
  });

  group('drekkana', () {
    test('first third: Narada, stays in sign', () {
      final (lon, deity) = drekkana(5.0, zodiac);
      expect(deity, VargaDeity.narada);
      expect(lon, closeTo(15.0, 0.001));
    });

    test('second third: Agastya, trine', () {
      final (lon, deity) = drekkana(15.0, zodiac);
      expect(deity, VargaDeity.agastya);
      expect(lon, closeTo(135.0, 0.001));
    });

    test('third third: Durvasas, trine-trine', () {
      final (lon, deity) = drekkana(25.0, zodiac);
      expect(deity, VargaDeity.durvasas);
      expect(lon, closeTo(255.0, 0.001));
    });

    test('sign 12 wraps correctly', () {
      // 335deg = sign 12, inSign = 5 (first third)
      final (lon, deity) = drekkana(335.0, zodiac);
      expect(deity, VargaDeity.narada);
      // baseLon(12, 0) = 330, newLon = 330 + (5/10)*30 = 345
      expect(lon, closeTo(345.0, 0.001));
    });
  });

  group('chaturthamsha', () {
    test('first quarter: Sanaka', () {
      final (_, deity) = chaturthamsha(3.0, zodiac);
      expect(deity, VargaDeity.sanaka);
    });

    test('fourth quarter: Sanatana', () {
      // 28deg in sign 1, 28 >= 22.5
      final (_, deity) = chaturthamsha(28.0, zodiac);
      expect(deity, VargaDeity.sanatana);
    });
  });

  group('parivritti', () {
    test('navamsha (amsha 9) at 0deg', () {
      final (lon, deity) = parivritti(0.0, 9, zodiac);
      expect(lon, closeTo(0.0, 0.001));
      expect(deity, isNotNull);
    });

    test('hora parivritti: odd sign, odd portion -> Sun', () {
      final (_, deity) = parivritti(0.0, 2, zodiac);
      expect(deity, VargaDeity.sun);
    });

    test('hora parivritti: odd sign, even portion -> Moon', () {
      // 16deg: amshaSize = 15, amshaElapsed = 1, (1+1).isOdd = false
      final (_, deity) = parivritti(16.0, 2, zodiac);
      expect(deity, VargaDeity.moon);
    });

    test('hora parivritti: even sign, odd portion -> Moon', () {
      // 30deg = sign 2 (even), amshaElapsed = 0, (0+1).isOdd = true
      final (_, deity) = parivritti(30.0, 2, zodiac);
      expect(deity, VargaDeity.moon);
    });

    test('various amsha counts produce valid results', () {
      for (final amsha in [3, 7, 9, 12, 27, 60]) {
        final result = parivritti(45.0, amsha, zodiac);
        expect(result.$1, isNotNaN, reason: 'amsha=$amsha');
      }
    });
  });

  group('dashamsha', () {
    test('odd sign counts forward from itself', () {
      // 5deg in sign 1 (odd), amshaSize = 3, elapsed = 1
      final (lon, _) = dashamsha(5.0, zodiac);
      // baseLon = 0, newLon = 0 + 30 + fraction*30
      expect(lon, closeTo(50.0, 0.1));
    });

    test('even sign counts from 9th sign', () {
      // 35deg = sign 2 (even), inSign = 5
      final (lon, _) = dashamsha(35.0, zodiac);
      // evenStart = (1+8)%12 = 9, baseLonEven = baseLon(10, 0) = 270
      expect(lon, greaterThanOrEqualTo(270));
    });

    test('even reversed changes direction', () {
      final normal = dashamsha(35.0, zodiac);
      final reversed = dashamsha(35.0, zodiac, evenReversed: true);
      expect(normal.$1, isNot(closeTo(reversed.$1, 0.001)));
    });
  });

  group('siddhamsha', () {
    test('odd sign starts from Leo (sign 5)', () {
      // baseLon(5, 0) = 120
      final (lon, _) = siddhamsha(5.0, zodiac);
      expect(lon, greaterThanOrEqualTo(120));
    });

    test('parashara vs default differ for even signs', () {
      final normal = siddhamsha(35.0, zodiac);
      final para = siddhamsha(35.0, zodiac, parashara: true);
      expect(normal.$1, isNot(closeTo(para.$1, 0.001)));
    });
  });

  group('trimsamsha', () {
    test('odd sign: Mars portion (0-5deg)', () {
      // 4deg in sign 1: Mars -> Aries (sign 1), baseLon = 0
      final (lon, deity) = trimsamsha(4.0, zodiac);
      expect(deity, isNull);
      // posInPortion = 4/5 = 0.8, newLon = 0 + 0.8*30 = 24
      expect(lon, closeTo(24.0, 0.001));
    });

    test('odd sign: Saturn portion (5-10deg)', () {
      final (lon, _) = trimsamsha(7.0, zodiac);
      // prevEnd = 5, portionSize = 5, posInPortion = 2/5 = 0.4
      // baseLon(11, 0) = 300, newLon = 300 + 12 = 312
      expect(lon, closeTo(312.0, 0.001));
    });

    test('even sign uses reversed table', () {
      // 34deg = sign 2 (even), inSign = 4, Venus portion (0-5)
      // baseLon(2, 0) = 30, posInPortion = 4/5 = 0.8
      final (lon, _) = trimsamsha(34.0, zodiac);
      expect(lon, closeTo(54.0, 0.001));
    });

    test('boundary between portions', () {
      // Exactly 5deg in sign 1: 5 < 10 -> Saturn portion
      final (lon, _) = trimsamsha(5.0, zodiac);
      // prevEnd = 5, portionSize = 5, posInPortion = 0/5 = 0
      // baseLon(11, 0) = 300
      expect(lon, closeTo(300.0, 0.001));
    });
  });

  group('shashtyamsha', () {
    test('basic D60 at 5deg', () {
      // sign 1, inSign = 5
      // calc = 10, remainder = 10, fromAmsha = 11
      // targetSign = (0+10)%12+1 = 11, baseLon(11, 0) = 300
      final (lon, _) = shashtyamsha(5.0, zodiac);
      expect(lon, greaterThanOrEqualTo(300));
      expect(lon, lessThan(330));
    });

    test('sign wrap in target calculation', () {
      // 10deg in sign 1: calc = 20, remainder = 8, fromAmsha = 9
      // targetSign = (0+8)%12+1 = 9, baseLon(9, 0) = 240
      final (lon, _) = shashtyamsha(10.0, zodiac);
      expect(lon, greaterThanOrEqualTo(240));
      expect(lon, lessThan(270));
    });
  });

  group('sign-12 wrap', () {
    test('dvadashamsha at 350deg (sign 12)', () {
      final (lon, deity) = dvadashamsha(350.0, zodiac);
      expect(lon, isNotNaN);
      expect(deity, isNotNull);
    });

    test('saptamsha at 359deg', () {
      final (lon, _) = saptamsha(359.0, zodiac);
      expect(lon, isNotNaN);
      expect(lon, greaterThanOrEqualTo(0));
    });

    test('bhamsha at boundary 0deg', () {
      final (lon, _) = bhamsha(0.0, zodiac);
      // sign 1 (fire), starts at Aries, baseLon = 0
      expect(lon, closeTo(0.0, 0.001));
    });
  });

  group('aditya offset', () {
    test('hora: 0deg zodiac=sign1(odd)->Sun, aditya=sign2(even)->Moon', () {
      final (_, deityZodiac) = hora(0.0, zodiac);
      final (_, deityAditya) = hora(0.0, aditya);
      expect(deityZodiac, VargaDeity.sun);
      expect(deityAditya, VargaDeity.moon);
    });

    test('khavedamsha with aditya offset changes sign parity', () {
      // 335deg: zodiac sign 12 (even) -> starts at Libra (sign 7)
      //         aditya sign 1 (odd) -> starts at Aries (sign 1)
      final rZodiac = khavedamsha(335.0, zodiac);
      final rAditya = khavedamsha(335.0, aditya);
      expect(rZodiac.$1, isNot(closeTo(rAditya.$1, 0.001)));
    });
  });
}
