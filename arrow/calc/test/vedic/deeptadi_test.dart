import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

import '../helpers/stub_varga.dart';

void main() {
  group('Deeptadi.of — priority cascade', () {
    test('step 1 — exalted → deepta', () {
      // Jupiter in Cancer → exalted
      final v = stubVarga(longitudes: {Body.jupiter: 100.0});
      expect(Deeptadi.of(Body.jupiter, v), DeeptadiState.deepta);
    });

    test('step 2 — ownSign → swastha', () {
      // Jupiter in Sagittarius → own sign
      final v = stubVarga(longitudes: {Body.jupiter: 260.0});
      expect(Deeptadi.of(Body.jupiter, v), DeeptadiState.swastha);
    });

    test('step 3 — friend / greatFriend → mudita', () {
      // Jupiter in Aquarius (lord=Saturn, nat.neutral) + Saturn 1 sign away → friend
      final v1 = stubVarga(longitudes: {
        Body.jupiter: 310.0, // Aquarius (sign 11)
        Body.saturn: 340.0, // Pisces (sign 12), apart=1 → temp friend
      });
      expect(Deeptadi.of(Body.jupiter, v1), DeeptadiState.mudita);

      // Jupiter in Leo (lord=Sun, nat.friend) + Sun 1 sign away → greatFriend
      final v2 = stubVarga(longitudes: {
        Body.jupiter: 130.0, // Leo (sign 5)
        Body.sun: 95.0, // Cancer (sign 4), apart=11 → temp friend
      });
      expect(Deeptadi.of(Body.jupiter, v2), DeeptadiState.mudita);
    });

    test('step 4 — benefic navamsa → shanta', () {
      // Jupiter neutral dignity + navamsa sign 4 (benefic).
      // Leo (lord=Sun, nat.friend) + Sun far away → temp enemy → neutral.
      // 130° → navamsa sign = floor(130/3.333)%12 + 1 = 39%12+1 = 4 (Cancer, benefic).
      final v = stubVarga(longitudes: {
        Body.jupiter: 130.0, // Leo
        Body.sun: 280.0, // Capricorn (sign 10), apart=5 → temp enemy → neutral
      });
      expect(Deeptadi.of(Body.jupiter, v), DeeptadiState.shanta);
    });

    test('step 5 — retrograde → shakta (when earlier steps fail)', () {
      // Neutral dignity + non-benefic navamsa (sign 1) + retrograde.
      // Aries (lord=Mars, nat.friend) + Mars far → temp enemy → neutral.
      // 1° → navamsa sign = floor(1/3.333)%12 + 1 = 0%12+1 = 1 (not benefic).
      final v = stubVarga(
        longitudes: {
          Body.jupiter: 1.0,
          Body.sun: 180.0, // far from Jupiter
          Body.mars: 160.0, // Virgo (sign 6), apart=5 → temp enemy
        },
        speeds: {Body.jupiter: -0.3},
      );
      expect(Deeptadi.of(Body.jupiter, v), DeeptadiState.shakta);
    });

    test('step 7 — debilitated (no earlier trigger) → deena', () {
      // Jupiter in Capricorn → debilitated.
      // 280° → navamsa sign = floor(280/3.333)%12 + 1 = 84%12+1 = 1 (not benefic).
      // All malefics far from Capricorn (270-300°).
      final v = stubVarga(longitudes: {
        Body.jupiter: 280.0, // Capricorn → debilitated
        Body.sun: 100.0,
        Body.mars: 200.0,
        Body.saturn: 40.0,
        Body.rahu: 200.0,
        Body.ketu: 20.0,
      });
      expect(Deeptadi.of(Body.jupiter, v), DeeptadiState.deena);
    });

    test('step 9 — enemy sign → khala', () {
      // Aquarius (lord=Saturn, nat.neutral) + Saturn far → temp enemy → enemy.
      // 310° → navamsa sign 10 (not benefic). Not retrograde, not debilitated,
      // no malefic conjunction, not combust.
      final v = stubVarga(longitudes: {
        Body.jupiter: 310.0, // Aquarius (sign 11)
        Body.saturn: 100.0, // Cancer (sign 4), apart=5 → temp enemy → enemy
        Body.sun: 100.0,
        Body.mars: 200.0,
        Body.rahu: 200.0,
        Body.ketu: 20.0,
      });
      expect(Deeptadi.of(Body.jupiter, v), DeeptadiState.khala);
    });
  });
}
