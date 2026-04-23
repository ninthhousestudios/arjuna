import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

/// Build a graha longitude map at scattered positions. Callers override
/// specific bodies to create the conditions they want to test.
Map<Body, double> _scattered({Map<Body, double> override = const {}}) {
  // 40° apart, no two in the same sign.
  final base = <Body, double>{
    Body.sun: 10.0,
    Body.moon: 50.0,
    Body.mars: 90.0,
    Body.mercury: 130.0,
    Body.jupiter: 170.0,
    Body.venus: 210.0,
    Body.saturn: 250.0,
    Body.rahu: 290.0,
    Body.ketu: 110.0,
  };
  return {...base, ...override};
}

/// Minimum dignity map: everyone neutral unless overridden.
Map<Body, DignityType> _neutralDignities(
    {Map<Body, DignityType> override = const {}}) {
  final base = {
    for (final k in [
      Body.sun, Body.moon, Body.mars, Body.mercury,
      Body.jupiter, Body.venus, Body.saturn,
    ])
      k: DignityType.neutral,
  };
  return {...base, ...override};
}

/// Sign per karaka matching a scattered-longitude chart (sign = floor(lon/30)+1).
Map<Body, int> _signsFromLongitudes(Map<Body, double> longs) => {
      for (final b in [
        Body.sun, Body.moon, Body.mars, Body.mercury,
        Body.jupiter, Body.venus, Body.saturn,
      ])
        b: (longs[b]! / 30).floor() + 1,
    };

void main() {
  group('Lajjitaadi — per-state unit tests', () {
    test('delighted — karaka conjunct Jupiter', () {
      // Venus conjunct Jupiter in Leo.
      final longs = _scattered(override: {
        Body.venus: 120.0, // Leo (sign 5)
        Body.jupiter: 125.0, // same sign
      });
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 5,
      );
      final venus = got[Body.venus]!;
      expect(venus.avasthas[LajjitaadiState.delighted], isNotEmpty);
      final f = venus.avasthas[LajjitaadiState.delighted]!
          .firstWhere((f) => f.planet == Body.jupiter);
      expect(f.source, 'conjunction');
      expect(f.strength, 60);
    });

    test('starved — karaka conjunct Saturn', () {
      // Mercury conjunct Saturn. Mercury + Saturn = N naturally.
      // The conj-Saturn branch fires regardless of friendship.
      final longs = _scattered(override: {
        Body.mercury: 250.0, // Sagittarius
        Body.saturn: 255.0, // same sign
      });
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 5,
      );
      final mercury = got[Body.mercury]!;
      final starved = mercury.avasthas[LajjitaadiState.starved]!;
      expect(starved.any((f) => f.planet == Body.saturn),
          isTrue, reason: 'Mercury should be starved by Saturn conj');
    });

    test('agitated — karaka conjunct Sun', () {
      // Moon conjunct Sun. (Moon + Sun = F naturally → also delighted via friend.)
      final longs = _scattered(override: {
        Body.sun: 60.0,
        Body.moon: 65.0,
      });
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 5,
      );
      final moon = got[Body.moon]!;
      expect(
          moon.avasthas[LajjitaadiState.agitated]!
              .any((f) => f.planet == Body.sun),
          isTrue);
    });

    test('thirsty — karaka in water sign aspected by natural enemy', () {
      // Mercury in Cancer (water, sign 4) aspected by Moon (enemy).
      // Place Moon 180° away to hit the opposition aspect slot.
      final longs = _scattered(override: {
        Body.mercury: 100.0, // Cancer
        Body.moon: 280.0, // 180° away
      });
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 5,
      );
      final mercury = got[Body.mercury]!;
      expect(mercury.avasthas[LajjitaadiState.thirsty], isNotEmpty);
      expect(
          mercury.avasthas[LajjitaadiState.thirsty]!
              .any((f) => f.planet == Body.moon),
          isTrue);
    });

    test('shamed — conj Sun/Mars/Saturn AND in 5th sign from lagna', () {
      // Lagna = Aries (1) → 5th sign = Leo (5). Put Jupiter conj Saturn in Leo.
      final longs = _scattered(override: {
        Body.jupiter: 120.0, // Leo
        Body.saturn: 125.0, // conj in Leo
      });
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 5,
      );
      final jupiter = got[Body.jupiter]!;
      final shamed = jupiter.avasthas[LajjitaadiState.shamed]!;
      expect(shamed.any((f) => f.planet == Body.saturn), isTrue);
      expect(
          shamed.any((f) =>
              f.source == 'condition' && f.detail == 'in 5th sign'),
          isTrue);
    });

    test('healthy — karaka in own sign', () {
      final longs = _scattered();
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(override: {
          Body.sun: DignityType.ownSign,
        }),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 5,
      );
      final sun = got[Body.sun]!;
      final healthy = sun.avasthas[LajjitaadiState.healthy]!;
      expect(healthy, hasLength(1));
      expect(healthy.first.source, 'sign');
      expect(healthy.first.strength, 60);
    });

    test('proud — karaka exalted', () {
      final longs = _scattered();
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(override: {
          Body.moon: DignityType.exalted,
        }),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 5,
      );
      final moon = got[Body.moon]!;
      final proud = moon.avasthas[LajjitaadiState.proud]!;
      expect(proud, hasLength(1));
      expect(proud.first.dignity, 'EX');
    });

    test('proud — karaka in moolatrikona', () {
      final longs = _scattered();
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(override: {
          Body.saturn: DignityType.moolatrikona,
        }),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 5,
      );
      final saturn = got[Body.saturn]!;
      expect(saturn.avasthas[LajjitaadiState.proud]!.first.dignity, 'MT');
    });

    test('giving/receiving — bidirectional pass populates both sides', () {
      // Sun and Jupiter are mutual natural friends, so conjunction makes
      // each delighted by the other — both giving and receiving flow.
      final longs = _scattered(override: {
        Body.sun: 120.0,
        Body.jupiter: 125.0,
      });
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 5,
      );
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
      // Put all bodies scattered, no dignity triggers. With scattered longs,
      // aspects between friend/enemy pairs may still fire → exercise the
      // "might or might not be present" contract: the result never contains
      // an empty LajjitaadiResult.
      final longs = _scattered();
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 5,
      );
      for (final entry in got.entries) {
        expect(entry.value.avasthas, isNotEmpty,
            reason: '${entry.key.name} present but empty');
      }
    });

    test('starved — karaka conjunct natural enemy', () {
      // Sun and Saturn are natural enemies.
      final longs = _scattered(override: {
        Body.sun: 250.0,
        Body.saturn: 255.0,
      });
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 5,
      );
      final sun = got[Body.sun]!;
      final starved = sun.avasthas[LajjitaadiState.starved]!;
      expect(starved.where((f) => f.planet == Body.saturn).length,
          greaterThanOrEqualTo(2),
          reason: 'enemy conj + Saturn-always-starves both fire');
    });

    test('delighted — sign lord is natural friend', () {
      // Mars in Leo (sign 5). Lord of Leo = Sun. Mars ↔ Sun = friend.
      final longs = _scattered(override: {Body.mars: 140.0});
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 10,
      );
      final mars = got[Body.mars]!;
      final delighted = mars.avasthas[LajjitaadiState.delighted] ?? [];
      expect(
          delighted.any((f) => f.source == 'sign' && f.lord == Body.sun),
          isTrue,
          reason: 'Mars should be delighted by Sun as lord of Leo');
    });

    test('shamed — conj Sun/Mars/Saturn AND conjunct Rahu/Ketu', () {
      // Venus conj Mars conj Rahu — triggers shamed via Rahu path.
      final longs = _scattered(override: {
        Body.venus: 200.0,
        Body.mars: 205.0,
        Body.rahu: 203.0,
      });
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 10,
      );
      final venus = got[Body.venus]!;
      final shamed = venus.avasthas[LajjitaadiState.shamed]!;
      expect(shamed.any((f) => f.planet == Body.mars), isTrue);
      expect(
          shamed.any(
              (f) => f.source == 'condition' && f.detail == 'conjunct Rahu/Ketu'),
          isTrue);
    });

    test('shamed — conjunct 5th cusp (not in 5th sign from lagna)', () {
      // Jupiter conj Saturn, 5th cusp sign = 8, lagna = 6 (5th sign = 10).
      final longs = _scattered(override: {
        Body.jupiter: 220.0, // Scorpio (sign 8)
        Body.saturn: 225.0,
      });
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 6,
        fifthCuspSign: 8,
      );
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
      final longs = _scattered(override: {
        Body.sun: 100.0,
        Body.saturn: 280.0,
      });
      final got = Lajjitaadi.compute(
        grahaLongitudes: longs,
        karakaDignities: _neutralDignities(),
        karakaSigns: _signsFromLongitudes(longs),
        lagnaSign: 1,
        fifthCuspSign: 5,
      );
      final sun = got[Body.sun]!;
      final agitated = sun.avasthas[LajjitaadiState.agitated] ?? [];
      expect(agitated.any((f) => f.planet == Body.saturn), isTrue,
          reason: 'Sun agitated by malefic enemy Saturn aspect');
    });
  });
}
