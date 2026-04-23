import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:test/test.dart';

import 'helpers/stub_snapshot.dart';

void main() {
  group('Dignity — Exaltation', () {
    test('Sun in Aries is exalted', () {
      expect(Dignity.isExalted(Body.sun, 1, 10.0), isTrue);
    });

    test('Sun in Aries at any degree is exalted (whole sign)', () {
      expect(Dignity.isExalted(Body.sun, 1, 25.0), isTrue);
    });

    test('Sun in Leo is not exalted', () {
      expect(Dignity.isExalted(Body.sun, 5, 10.0), isFalse);
    });

    test('Moon in Taurus before 3° is exalted', () {
      expect(Dignity.isExalted(Body.moon, 2, 2.0), isTrue);
    });

    test('Moon in Taurus after 3° is not exalted', () {
      expect(Dignity.isExalted(Body.moon, 2, 5.0), isFalse);
    });

    test('Mercury in Virgo before 15° is exalted', () {
      expect(Dignity.isExalted(Body.mercury, 6, 10.0), isTrue);
    });

    test('Mercury in Virgo after 15° is not exalted', () {
      expect(Dignity.isExalted(Body.mercury, 6, 18.0), isFalse);
    });
  });

  group('Dignity — Debilitation', () {
    test('Sun in Libra is debilitated', () {
      expect(Dignity.isDebilitated(Body.sun, 7, 10.0), isTrue);
    });

    test('Moon in Scorpio before 3° is debilitated', () {
      expect(Dignity.isDebilitated(Body.moon, 8, 1.0), isTrue);
    });

    test('Moon in Scorpio after 3° is not debilitated', () {
      expect(Dignity.isDebilitated(Body.moon, 8, 5.0), isFalse);
    });

    test('Saturn in Aries is debilitated', () {
      expect(Dignity.isDebilitated(Body.saturn, 1, 20.0), isTrue);
    });
  });

  group('Dignity — Moolatrikona', () {
    test('Sun in Leo 0-20° is moolatrikona', () {
      expect(Dignity.isMoolatrikona(Body.sun, 5, 10.0), isTrue);
    });

    test('Sun in Leo after 20° is not moolatrikona', () {
      expect(Dignity.isMoolatrikona(Body.sun, 5, 25.0), isFalse);
    });

    test('Moon in Taurus 3-30° is moolatrikona', () {
      expect(Dignity.isMoolatrikona(Body.moon, 2, 10.0), isTrue);
    });

    test('Moon in Taurus before 3° is not moolatrikona (exalted)', () {
      expect(Dignity.isMoolatrikona(Body.moon, 2, 1.0), isFalse);
    });

    test('Mercury in Virgo 15-20° is moolatrikona', () {
      expect(Dignity.isMoolatrikona(Body.mercury, 6, 17.0), isTrue);
    });
  });

  group('Dignity — Own Sign', () {
    test('Sun in Leo after 20° is own sign', () {
      expect(Dignity.isOwnSign(Body.sun, 5, 25.0), isTrue);
    });

    test('Sun in Leo before 20° is not own sign (moolatrikona)', () {
      expect(Dignity.isOwnSign(Body.sun, 5, 10.0), isFalse);
    });

    test('Moon in Cancer is own sign', () {
      expect(Dignity.isOwnSign(Body.moon, 4, 15.0), isTrue);
    });

    test('Mars in Scorpio is own sign', () {
      expect(Dignity.isOwnSign(Body.mars, 8, 15.0), isTrue);
    });

    test('Mars in Aries after 12° is own sign', () {
      expect(Dignity.isOwnSign(Body.mars, 1, 15.0), isTrue);
    });

    test('Mars in Aries before 12° is not own sign (moolatrikona)', () {
      expect(Dignity.isOwnSign(Body.mars, 1, 5.0), isFalse);
    });

    test('Mercury in Gemini is own sign', () {
      expect(Dignity.isOwnSign(Body.mercury, 3, 15.0), isTrue);
    });

    test('Mercury in Virgo after 20° is own sign', () {
      expect(Dignity.isOwnSign(Body.mercury, 6, 25.0), isTrue);
    });
  });

  group('Dignity — Natural Friendship', () {
    test('Sun-Moon are friends', () {
      expect(Dignity.isNaturalFriend(Body.sun, Body.moon), isTrue);
    });

    test('Sun-Venus are enemies', () {
      expect(Dignity.isNaturalEnemy(Body.sun, Body.venus), isTrue);
    });

    test('Sun-Mercury are neutral', () {
      expect(Dignity.isNaturalFriend(Body.sun, Body.mercury), isFalse);
      expect(Dignity.isNaturalEnemy(Body.sun, Body.mercury), isFalse);
    });
  });

  group('Dignity — Temporary Friendship', () {
    test('2 signs apart is temporary friend', () {
      expect(Dignity.isTemporaryFriend(1, 3), isTrue);
    });

    test('4 signs apart is temporary friend', () {
      expect(Dignity.isTemporaryFriend(1, 5), isFalse); // 4 apart = not friend
    });

    test('5 signs apart is not temporary friend', () {
      expect(Dignity.isTemporaryFriend(1, 6), isFalse);
    });

    test('10 signs apart is temporary friend', () {
      expect(Dignity.isTemporaryFriend(1, 11), isTrue);
    });

    test('wraps around correctly', () {
      // Sign 12 to sign 2 = 2 apart
      expect(Dignity.isTemporaryFriend(12, 2), isTrue);
    });
  });

  group('Dignity — Compound Friendship', () {
    test('natural friend + temp friend = great friend', () {
      // Sun and Moon are natural friends. Put them 2 signs apart.
      final level = Dignity.compoundFriendship(Body.sun, Body.moon, 1, 3);
      expect(level, FriendshipLevel.greatFriend);
    });

    test('natural enemy + temp enemy = great enemy', () {
      // Sun and Saturn are natural enemies. Put them 5 signs apart (not temp friend).
      final level = Dignity.compoundFriendship(Body.sun, Body.saturn, 1, 6);
      expect(level, FriendshipLevel.greatEnemy);
    });

    test('natural neutral + temp friend = friend', () {
      // Sun and Mercury are natural neutrals.
      final level = Dignity.compoundFriendship(Body.sun, Body.mercury, 1, 3);
      expect(level, FriendshipLevel.friend);
    });

    test('natural neutral + temp enemy = enemy', () {
      final level = Dignity.compoundFriendship(Body.sun, Body.mercury, 1, 6);
      expect(level, FriendshipLevel.enemy);
    });
  });

  group('Dignity — Calculate', () {
    test('Sun in Aries is exalted', () {
      final d = Dignity.calculate(Body.sun, 1, 10.0, 1);
      expect(d, DignityType.exalted);
    });

    test('Sun in Libra is debilitated', () {
      final d = Dignity.calculate(Body.sun, 7, 10.0, 7);
      expect(d, DignityType.debilitated);
    });

    test('Sun in Leo 10° is moolatrikona', () {
      final d = Dignity.calculate(Body.sun, 5, 10.0, 5);
      expect(d, DignityType.moolatrikona);
    });

    test('Sun in Leo 25° is own sign', () {
      final d = Dignity.calculate(Body.sun, 5, 25.0, 5);
      expect(d, DignityType.ownSign);
    });

    test('exalted overrides friendship', () {
      // Moon at 2° Taurus (exalted zone). Lord is Venus.
      final d = Dignity.calculate(Body.moon, 2, 2.0, 7);
      expect(d, DignityType.exalted);
    });
  });

  group('Dignity — Combustion', () {
    test('Mercury near Sun is combust', () {
      // Mercury at 50°, Sun at 45° = 5° apart < 14° orb
      expect(Dignity.isCombust(Body.mercury, 50.0, 45.0), isTrue);
    });

    test('Mercury far from Sun is not combust', () {
      // Mercury at 80°, Sun at 45° = 35° apart > 14° orb
      expect(Dignity.isCombust(Body.mercury, 80.0, 45.0), isFalse);
    });

    test('Mercury retrograde uses tighter orb', () {
      // 13° apart: > retrograde orb (12) but < normal orb (14)
      expect(
          Dignity.isCombust(Body.mercury, 58.0, 45.0, isRetrograde: true),
          isFalse);
      expect(Dignity.isCombust(Body.mercury, 58.0, 45.0), isTrue);
    });

    test('Sun is never combust', () {
      expect(Dignity.isCombust(Body.sun, 45.0, 45.0), isFalse);
    });

    test('Rahu is never combust', () {
      expect(Dignity.isCombust(Body.rahu, 45.0, 45.0), isFalse);
    });

    test('Venus combustion orb is 10°', () {
      // 9° apart < 10° orb
      expect(Dignity.isCombust(Body.venus, 54.0, 45.0), isTrue);
      // 11° apart > 10° orb
      expect(Dignity.isCombust(Body.venus, 56.0, 45.0), isFalse);
    });
  });

  group('CharaKaraka', () {
    test('sorts karakas by in-sign longitude descending', () {
      // Create karakas with known in-sign longitudes
      final result = CharaKaraka.assign(_makeKarakas());
      expect(result.length, 7);
      expect(result.containsKey(CharaKarakaRole.atmakaraka), isTrue);
      expect(result.containsKey(CharaKarakaRole.darakaraka), isTrue);

      // Atmakaraka should have highest inSignLongitude
      final ak = result[CharaKarakaRole.atmakaraka]!;
      final dk = result[CharaKarakaRole.darakaraka]!;
      expect(ak.inSignLongitude, greaterThanOrEqualTo(dk.inSignLongitude));
    });

    test('8 karaka mode includes all 8 roles', () {
      final karakas = _makeKarakas();
      final snapshot = stubSnapshot();
      karakas.add(Karaka(Body.rahu, snapshot, const CalcConfig(),
          VargaType.rashi));

      final result = CharaKaraka.assign(karakas, count: 8);
      expect(result.length, 8);
      expect(result.containsKey(CharaKarakaRole.striDarakaraka), isTrue);
    });

    test('atmakaraka has highest in-sign longitude', () {
      final result = CharaKaraka.assign(_makeKarakas());
      final ak = result[CharaKarakaRole.atmakaraka]!;
      for (final entry in result.entries) {
        expect(ak.inSignLongitude,
            greaterThanOrEqualTo(entry.value.inSignLongitude));
      }
    });
  });
}

/// Helper to create test karakas.
List<Karaka> _makeKarakas() {
  final snapshot = stubSnapshot();
  const config = CalcConfig();
  final sunLon = snapshot.bodiesEcliptic[Body.sun]?.longitude;
  return Body.karakas
      .map((b) =>
          Karaka(b, snapshot, config, VargaType.rashi, sunLongitude: sunLon))
      .toList();
}
