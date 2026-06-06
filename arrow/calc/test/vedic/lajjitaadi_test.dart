import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

import '../helpers/stub_varga.dart';

/// Scattered positions — 40° apart, no two in the same sign.
/// Default cusps give lagnaSign=1 (Aries), fifthCuspSign=5 (Leo).
Varga _scattered({Map<Body, double> override = const {}}) {
  return stubVarga(longitudes: {
    Body.sun: 10.0,
    Body.moon: 50.0,
    Body.mars: 90.0,
    Body.mercury: 130.0,
    Body.jupiter: 170.0,
    Body.venus: 210.0,
    Body.saturn: 250.0,
    Body.rahu: 290.0,
    Body.ketu: 110.0,
    ...override,
  });
}

void main() {
  group('Lajjitaadi — per-state unit tests', () {
    test('delighted — karaka conjunct Jupiter', () {
      // Venus conjunct Jupiter in Leo.
      final v = _scattered(override: {
        Body.venus: 120.0, // Leo (sign 5)
        Body.jupiter: 125.0, // same sign
      });
      final got = Lajjitaadi.compute(v);
      final venus = got[Body.venus]!;
      expect(venus.avasthas[LajjitaadiState.delighted], isNotEmpty);
      final f = venus.avasthas[LajjitaadiState.delighted]!
          .firstWhere((f) => f.planet == Body.jupiter);
      expect(f.source, 'conjunction');
      expect(f.strength, 60);
    });

    test('starved — karaka conjunct Saturn', () {
      // Mercury conjunct Saturn.
      final v = _scattered(override: {
        Body.mercury: 250.0, // Sagittarius
        Body.saturn: 255.0, // same sign
      });
      final got = Lajjitaadi.compute(v);
      final mercury = got[Body.mercury]!;
      final starved = mercury.avasthas[LajjitaadiState.starved]!;
      expect(starved.any((f) => f.planet == Body.saturn),
          isTrue, reason: 'Mercury should be starved by Saturn conj');
    });

    test('agitated — karaka conjunct Sun', () {
      // Moon conjunct Sun.
      final v = _scattered(override: {
        Body.sun: 60.0,
        Body.moon: 65.0,
      });
      final got = Lajjitaadi.compute(v);
      final moon = got[Body.moon]!;
      expect(
          moon.avasthas[LajjitaadiState.agitated]!
              .any((f) => f.planet == Body.sun),
          isTrue);
    });

    test('thirsty — karaka in water sign aspected by natural enemy', () {
      // Mercury in Cancer (water, sign 4) aspected by Moon (enemy).
      // Place Moon 180° away to hit the opposition aspect slot.
      final v = _scattered(override: {
        Body.mercury: 100.0, // Cancer
        Body.moon: 280.0, // 180° away
      });
      final got = Lajjitaadi.compute(v);
      final mercury = got[Body.mercury]!;
      expect(mercury.avasthas[LajjitaadiState.thirsty], isNotEmpty);
      expect(
          mercury.avasthas[LajjitaadiState.thirsty]!
              .any((f) => f.planet == Body.moon),
          isTrue);
    });

    test('shamed — conj Sun/Mars/Saturn AND in 5th sign from lagna', () {
      // Lagna = Aries (1) → 5th sign = Leo (5). Put Jupiter conj Saturn in Leo.
      final v = _scattered(override: {
        Body.jupiter: 120.0, // Leo
        Body.saturn: 125.0, // conj in Leo
      });
      final got = Lajjitaadi.compute(v);
      final jupiter = got[Body.jupiter]!;
      final shamed = jupiter.avasthas[LajjitaadiState.shamed]!;
      expect(shamed.any((f) => f.planet == Body.saturn), isTrue);
      expect(
          shamed.any((f) =>
              f.source == 'condition' && f.detail == 'in 5th sign'),
          isTrue);
    });

    test('healthy — karaka in own sign', () {
      // Sun in Leo at 20° in-sign (past moolatrikona range 0-20°) → ownSign.
      final v = _scattered(override: {Body.sun: 140.0});
      final got = Lajjitaadi.compute(v);
      final sun = got[Body.sun]!;
      final healthy = sun.avasthas[LajjitaadiState.healthy]!;
      expect(healthy, hasLength(1));
      expect(healthy.first.source, 'sign');
      expect(healthy.first.strength, 60);
    });

    test('proud — karaka exalted', () {
      // Moon exalted in Taurus at 0-3°.
      final v = _scattered(override: {Body.moon: 31.0});
      final got = Lajjitaadi.compute(v);
      final moon = got[Body.moon]!;
      final proud = moon.avasthas[LajjitaadiState.proud]!;
      expect(proud, hasLength(1));
      expect(proud.first.dignity, 'EX');
    });

    test('proud — karaka in moolatrikona', () {
      // Saturn moolatrikona: Aquarius (sign 11) at 0-20°.
      final v = _scattered(override: {Body.saturn: 300.0});
      final got = Lajjitaadi.compute(v);
      final saturn = got[Body.saturn]!;
      expect(saturn.avasthas[LajjitaadiState.proud]!.first.dignity, 'MT');
    });

    test('giving/receiving — bidirectional pass populates both sides', () {
      // Sun and Jupiter are mutual natural friends, so conjunction makes
      // each delighted by the other.
      final v = _scattered(override: {
        Body.sun: 120.0,
        Body.jupiter: 125.0,
      });
      final got = Lajjitaadi.compute(v);
      final sun = got[Body.sun]!;
      expect(
          sun.receiving[LajjitaadiState.delighted]!
              .any((f) => f.planet == Body.jupiter),
          isTrue,
          reason: 'Sun should receive delight from Jupiter');
      expect(
          sun.giving[LajjitaadiState.delighted]!
              .any((f) => f.to == Body.jupiter),
          isTrue,
          reason: 'Sun should give delight to Jupiter');
    });

    test('karaka with no factors is omitted from the result map', () {
      final v = _scattered();
      final got = Lajjitaadi.compute(v);
      for (final entry in got.entries) {
        expect(entry.value.avasthas, isNotEmpty,
            reason: '${entry.key.name} present but empty');
      }
    });

    test('starved — karaka conjunct natural enemy', () {
      // Sun and Saturn are natural enemies.
      final v = _scattered(override: {
        Body.sun: 250.0,
        Body.saturn: 255.0,
      });
      final got = Lajjitaadi.compute(v);
      final sun = got[Body.sun]!;
      final starved = sun.avasthas[LajjitaadiState.starved]!;
      expect(starved.where((f) => f.planet == Body.saturn).length,
          greaterThanOrEqualTo(2),
          reason: 'enemy conj + Saturn-always-starves both fire');
    });

    test('delighted — sign lord is natural friend', () {
      // Mars in Leo (sign 5). Lord of Leo = Sun. Mars ↔ Sun = friend.
      final v = stubVarga(longitudes: {
        Body.sun: 10.0,
        Body.moon: 50.0,
        Body.mars: 140.0, // Leo
        Body.mercury: 130.0,
        Body.jupiter: 170.0,
        Body.venus: 210.0,
        Body.saturn: 250.0,
        Body.rahu: 290.0,
        Body.ketu: 110.0,
      }, cusps: List.generate(12, (i) => (i * 30.0 + 10.0) % 360));
      final got = Lajjitaadi.compute(v);
      final mars = got[Body.mars]!;
      final delighted = mars.avasthas[LajjitaadiState.delighted] ?? [];
      expect(
          delighted.any((f) => f.source == 'sign' && f.lord == Body.sun),
          isTrue,
          reason: 'Mars should be delighted by Sun as lord of Leo');
    });

    test('shamed — conj Sun/Mars/Saturn AND conjunct Rahu/Ketu', () {
      // Venus conj Mars conj Rahu — triggers shamed via Rahu path.
      final v = _scattered(override: {
        Body.venus: 200.0,
        Body.mars: 205.0,
        Body.rahu: 203.0,
      });
      final got = Lajjitaadi.compute(v);
      final venus = got[Body.venus]!;
      final shamed = venus.avasthas[LajjitaadiState.shamed]!;
      expect(shamed.any((f) => f.planet == Body.mars), isTrue);
      expect(
          shamed.any(
              (f) => f.source == 'condition' && f.detail == 'conjunct Rahu/Ketu'),
          isTrue);
    });

    test('shamed — conjunct 5th cusp (not in 5th sign from lagna)', () {
      // Jupiter conj Saturn, 5th cusp sign = 8, lagna = 6.
      final v = stubVarga(
        longitudes: {
          Body.sun: 10.0,
          Body.moon: 50.0,
          Body.mars: 90.0,
          Body.mercury: 130.0,
          Body.jupiter: 220.0, // Scorpio (sign 8)
          Body.venus: 310.0,
          Body.saturn: 225.0, // conj in Scorpio
          Body.rahu: 30.0,
          Body.ketu: 210.0,
        },
        cusps: [
          155.0, 185.0, 195.0, 215.0, 225.0, // cusp[0]=sign 6, cusp[4]=sign 8
          255.0, 285.0, 315.0, 345.0, 15.0, 45.0, 75.0,
        ],
      );
      final got = Lajjitaadi.compute(v);
      final jupiter = got[Body.jupiter]!;
      final shamed = jupiter.avasthas[LajjitaadiState.shamed]!;
      expect(
          shamed.any(
              (f) => f.source == 'condition' && f.detail == 'conjunct 5th cusp'),
          isTrue);
      expect(
          shamed.any(
              (f) => f.source == 'condition' && f.detail == 'in 5th sign'),
          isFalse,
          reason: '5th sign from lagna 6 is 10, not 8');
    });

    test('agitated — aspected by malefic natural enemy', () {
      // Sun and Saturn are natural enemies. Saturn is a natural malefic.
      // Place Saturn 180° from Sun for opposition aspect.
      final v = _scattered(override: {
        Body.sun: 100.0,
        Body.saturn: 280.0,
      });
      final got = Lajjitaadi.compute(v);
      final sun = got[Body.sun]!;
      final agitated = sun.avasthas[LajjitaadiState.agitated] ?? [];
      expect(agitated.any((f) => f.planet == Body.saturn), isTrue,
          reason: 'Sun agitated by malefic enemy Saturn aspect');
    });
  });
}
