import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';

// ─── Result types ────────────────────────────────────────────────────────────

sealed class YogaResult {
  String get name;
  String get category;
  int get toMove;
  bool get isPresent => toMove == 0;
}

class NabhasaYoga extends YogaResult {
  @override
  final String name;
  @override
  final String category;
  @override
  final int toMove;
  final List<int> houses;

  NabhasaYoga({
    required this.name,
    required this.category,
    required this.toMove,
    required this.houses,
  });
}

class MahapurushaYoga extends YogaResult {
  @override
  final String name;
  final Body planet;
  final bool present;
  final int? house;
  final DignityType? dignity;

  @override
  String get category => 'Panchamahapurusha';
  @override
  int get toMove => present ? 0 : 1;

  MahapurushaYoga({
    required this.name,
    required this.planet,
    required this.present,
    this.house,
    this.dignity,
  });
}

class SolarLunarYoga extends YogaResult {
  @override
  final String name;
  @override
  final String category;
  final List<Body> planets;
  final bool present;

  @override
  int get toMove => present ? 0 : 1;

  SolarLunarYoga({
    required this.name,
    required this.category,
    required this.planets,
    required this.present,
  });
}

// ─── Main calculator ─────────────────────────────────────────────────────────

class NabhasaYogaCalc {
  const NabhasaYogaCalc._();

  /// House number (1-12) of [signNum] from [lagnaSign].
  static int houseFrom(int lagnaSign, int signNum) =>
      ((signNum - lagnaSign + 12) % 12) + 1;

  // ── Private extraction helpers ──────────────────────────────────────────────

  static Map<int, List<Body>> _karakasPerHouse(Varga varga) {
    final lagnaSign = varga.cusps[0].sign;
    final map = <int, List<Body>>{};
    for (final k in varga.karakas) {
      final house = houseFrom(lagnaSign, k.sign);
      (map[house] ??= []).add(k.body);
    }
    return map;
  }

  static Map<int, Quality> _houseQualities(Varga varga) {
    final lagnaSign = varga.cusps[0].sign;
    return {
      for (var h = 1; h <= 12; h++)
        h: SignData.quality(((lagnaSign - 1 + h - 1) % 12) + 1),
    };
  }

  static bool _moonIsBenefic(Varga varga) =>
      Nature.ofMoon(
        sunLongitude: varga.sun.rawLongitude,
        moonLongitude: varga.moon.rawLongitude,
      ) ==
      Nature.benefic;

  // ── toMove helpers ──────────────────────────────────────────────────────────

  /// 7 - (karakas in the given houses). How many karakas are outside.
  static int _tm(Map<int, List<Body>> kph, List<int> houses) {
    var inHouses = 0;
    for (final h in houses) {
      inHouses += (kph[h] ?? const []).length;
    }
    return 7 - inHouses;
  }

  /// max(outside, emptyRequiredHouses).
  static int _tmDist(Map<int, List<Body>> kph, List<int> houses) {
    var inHouses = 0;
    var empty = 0;
    for (final h in houses) {
      final count = (kph[h] ?? const []).length;
      inHouses += count;
      if (count == 0) empty++;
    }
    final outside = 7 - inHouses;
    return outside > empty ? outside : empty;
  }

  // ── Ashraya ─────────────────────────────────────────────────────────────────

  /// All 7 karakas in signs of one modality.
  static List<NabhasaYoga> ashrayaYogas(Varga varga) {
    final karakasPerHouse = _karakasPerHouse(varga);
    final houseQualities = _houseQualities(varga);
    final cardinal = <int>[];
    final fixed = <int>[];
    final mutable = <int>[];

    for (var h = 1; h <= 12; h++) {
      switch (houseQualities[h] ?? Quality.cardinal) {
        case Quality.cardinal:
          cardinal.add(h);
        case Quality.fixed:
          fixed.add(h);
        case Quality.mutable:
          mutable.add(h);
      }
    }

    return [
      NabhasaYoga(
        name: 'Rajju',
        category: 'Ashraya',
        toMove: _tm(karakasPerHouse, cardinal),
        houses: cardinal,
      ),
      NabhasaYoga(
        name: 'Musala',
        category: 'Ashraya',
        toMove: _tm(karakasPerHouse, fixed),
        houses: fixed,
      ),
      NabhasaYoga(
        name: 'Nala',
        category: 'Ashraya',
        toMove: _tm(karakasPerHouse, mutable),
        houses: mutable,
      ),
    ];
  }

  // ── Dala ────────────────────────────────────────────────────────────────────

  /// Benefic/malefic in kendras (1,4,7,10).
  static List<NabhasaYoga> dalaYogas(Varga varga) {
    final karakasPerHouse = _karakasPerHouse(varga);
    final moonIsBenefic = _moonIsBenefic(varga);
    const kendras = [1, 4, 7, 10];

    // Conditional benefic/malefic: Moon classified by phase (moonIsBenefic).
    // Distinct from Jaimini._isMalefic which uses fixed natural malefics
    // (includes Rahu/Ketu, excludes Moon entirely).
    final benefics = <Body>[Body.mercury, Body.jupiter, Body.venus];
    final malefics = <Body>[Body.sun, Body.mars, Body.saturn];
    if (moonIsBenefic) {
      benefics.add(Body.moon);
    } else {
      malefics.add(Body.moon);
    }

    var beneficsInKendras = 0;
    var maleficsInKendras = 0;
    for (final h in kendras) {
      for (final b in (karakasPerHouse[h] ?? const [])) {
        if (benefics.contains(b)) beneficsInKendras++;
        if (malefics.contains(b)) maleficsInKendras++;
      }
    }

    return [
      NabhasaYoga(
        name: 'Mala',
        category: 'Dala',
        toMove: benefics.length - beneficsInKendras,
        houses: kendras,
      ),
      NabhasaYoga(
        name: 'Sarpa',
        category: 'Dala',
        toMove: malefics.length - maleficsInKendras,
        houses: kendras,
      ),
    ];
  }

  // ── Sankhya ──────────────────────────────────────────────────────────────────

  /// By occupied house count (exactly one always has toMove=0).
  static List<NabhasaYoga> sankhyaYogas({required int occupiedHouseCount}) {
    const yogas = [
      ('Veena', 7),
      ('Dama', 6),
      ('Pasa', 5),
      ('Kedara', 4),
      ('Sula', 3),
      ('Yuga', 2),
      ('Gola', 1),
    ];
    return [
      for (final (name, required) in yogas)
        NabhasaYoga(
          name: name,
          category: 'Sankhya',
          toMove: (occupiedHouseCount - required).abs(),
          houses: const [],
        ),
    ];
  }

  // ── Akriti ───────────────────────────────────────────────────────────────────

  static List<NabhasaYoga> akritiYogas(Varga varga) {
    final karakasPerHouse = _karakasPerHouse(varga);
    final moonIsBenefic = _moonIsBenefic(varga);
    final results = <NabhasaYoga>[];

    // 1. Trine patterns
    const trines = [
      ('Sringataka', [1, 5, 9]),
      ('Hala', [2, 6, 10]),
      ('Hala', [3, 7, 11]),
      ('Hala', [4, 8, 12]),
    ];
    for (final (name, houses) in trines) {
      results.add(NabhasaYoga(
        name: name,
        category: 'Akriti',
        toMove: _tm(karakasPerHouse, houses),
        houses: houses,
      ));
    }

    // 2. Angle pairs (Gada variants)
    const gadaGroups = [
      ('Gada', [1, 4]),
      ('Gada', [4, 7]),
      ('Gada', [7, 10]),
      ('Gada', [10, 1]),
    ];
    for (final (name, houses) in gadaGroups) {
      results.add(NabhasaYoga(
        name: name,
        category: 'Akriti',
        toMove: _tm(karakasPerHouse, houses),
        houses: houses,
      ));
    }

    // 3. Two-angle
    const twoAngle = [
      ('Sakata', [1, 7]),
      ('Vihaga', [4, 10]),
    ];
    for (final (name, houses) in twoAngle) {
      results.add(NabhasaYoga(
        name: name,
        category: 'Akriti',
        toMove: _tm(karakasPerHouse, houses),
        houses: houses,
      ));
    }

    // 4. Four-angle
    const fourAngle = [
      ('Kamala', [1, 4, 7, 10]),
      ('Vapi', [2, 5, 8, 11]),
      ('Vapi', [3, 6, 9, 12]),
    ];
    for (final (name, houses) in fourAngle) {
      results.add(NabhasaYoga(
        name: name,
        category: 'Akriti',
        toMove: _tm(karakasPerHouse, houses),
        houses: houses,
      ));
    }

    // 5. Vajra / Yava
    final benefics = <Body>[Body.mercury, Body.jupiter, Body.venus];
    final malefics = <Body>[Body.sun, Body.mars, Body.saturn];
    if (moonIsBenefic) {
      benefics.add(Body.moon);
    } else {
      malefics.add(Body.moon);
    }

    int countIn(List<Body> group, List<int> houses) {
      var n = 0;
      for (final h in houses) {
        for (final b in (karakasPerHouse[h] ?? const [])) {
          if (group.contains(b)) n++;
        }
      }
      return n;
    }

    final vajraScore = 7 -
        (countIn(benefics, const [1, 7]) +
            countIn(malefics, const [4, 10]));
    results.add(NabhasaYoga(
      name: 'Vajra',
      category: 'Akriti',
      toMove: vajraScore,
      houses: const [1, 4, 7, 10],
    ));

    final yavaScore = 7 -
        (countIn(benefics, const [4, 10]) +
            countIn(malefics, const [1, 7]));
    results.add(NabhasaYoga(
      name: 'Yava',
      category: 'Akriti',
      toMove: yavaScore,
      houses: const [1, 4, 7, 10],
    ));

    // 6. Four-consecutive
    const fourConsec = [
      ('Yupa', [1, 2, 3, 4]),
      ('Sara', [4, 5, 6, 7]),
      ('Shakti', [7, 8, 9, 10]),
      ('Danda', [10, 11, 12, 1]),
    ];
    for (final (name, houses) in fourConsec) {
      results.add(NabhasaYoga(
        name: name,
        category: 'Akriti',
        toMove: _tm(karakasPerHouse, houses),
        houses: houses,
      ));
    }

    // 7. Seven-consecutive
    const sevenConsec = [
      ('Nauka', [1, 2, 3, 4, 5, 6, 7]),
      ('Kuta', [4, 5, 6, 7, 8, 9, 10]),
      ('Chatra', [7, 8, 9, 10, 11, 12, 1]),
      ('Chapa', [10, 11, 12, 1, 2, 3, 4]),
    ];
    for (final (name, houses) in sevenConsec) {
      results.add(NabhasaYoga(
        name: name,
        category: 'Akriti',
        toMove: _tmDist(karakasPerHouse, houses),
        houses: houses,
      ));
    }

    // 8. Ardha Chandra — 7-house runs from non-angle houses (2,3,5,6,8,9,11,12)
    const ardhaStarts = [2, 3, 5, 6, 8, 9, 11, 12];
    for (var i = 0; i < ardhaStarts.length; i++) {
      final start = ardhaStarts[i];
      final houses = [
        for (var k = 0; k < 7; k++) ((start - 1 + k) % 12) + 1,
      ];
      results.add(NabhasaYoga(
        name: 'ArdhaChandra${i + 1}',
        category: 'Akriti',
        toMove: _tmDist(karakasPerHouse, houses),
        houses: houses,
      ));
    }

    // 9. Alternate-6
    const altSix = [
      ('Chakra', [1, 3, 5, 7, 9, 11]),
      ('Samudra', [2, 4, 6, 8, 10, 12]),
    ];
    for (final (name, houses) in altSix) {
      results.add(NabhasaYoga(
        name: name,
        category: 'Akriti',
        toMove: _tmDist(karakasPerHouse, houses),
        houses: houses,
      ));
    }

    return results;
  }

  // ── Combined Nabhasa ─────────────────────────────────────────────────────────

  static List<NabhasaYoga> nabhasaYogas(Varga varga) {
    final kph = _karakasPerHouse(varga);
    final occupied = kph.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => e.key)
        .toSet()
        .length;

    return [
      ...ashrayaYogas(varga),
      ...dalaYogas(varga),
      ...sankhyaYogas(occupiedHouseCount: occupied),
      ...akritiYogas(varga),
    ];
  }

  // ── Panchamahapurusha ────────────────────────────────────────────────────────

  /// Ruchaka (Mars), Bhadra (Mercury), Hamsa (Jupiter), Malavya (Venus),
  /// Sasa (Saturn): planet in kendra (1,4,7,10) with exalted/moolatrikona/ownSign.
  static List<MahapurushaYoga> panchamahapurushaYogas(Varga varga) {
    final lagnaSign = varga.cusps[0].sign;
    const specs = [
      ('Ruchaka', Body.mars),
      ('Bhadra', Body.mercury),
      ('Hamsa', Body.jupiter),
      ('Malavya', Body.venus),
      ('Sasa', Body.saturn),
    ];
    const kendras = {1, 4, 7, 10};
    const strongDignities = {
      DignityType.exalted,
      DignityType.moolatrikona,
      DignityType.ownSign,
    };

    return [
      for (final (name, planet) in specs)
        () {
          final k = varga.karaka(planet);
          final house = houseFrom(lagnaSign, k.sign);
          final dignity = k.dignity;
          final present = kendras.contains(house) &&
              strongDignities.contains(dignity);
          return MahapurushaYoga(
            name: name,
            planet: planet,
            present: present,
            house: present ? house : null,
            dignity: present ? dignity : null,
          );
        }(),
    ];
  }

  // ── Solar yogas ──────────────────────────────────────────────────────────────

  /// Vesi, Vosi, Ubhayachari — planets in 2nd/12th from Sun's house.
  static List<SolarLunarYoga> solarYogas(Varga varga) {
    final lagnaSign = varga.cusps[0].sign;
    final karakasPerHouse = _karakasPerHouse(varga);
    final sunHouse = houseFrom(lagnaSign, varga.sun.sign);
    return _solarLunarYogas(
      karakasPerHouse: karakasPerHouse,
      refHouse: sunHouse,
      category: 'Solar',
      secondName: 'Vesi',
      twelfthName: 'Vosi',
      bothName: 'Ubhayachari',
    );
  }

  // ── Lunar yogas ──────────────────────────────────────────────────────────────

  /// Sunapha, Anapha, Durudhara, Kemadruma — planets near Moon.
  static List<SolarLunarYoga> lunarYogas(Varga varga) {
    final lagnaSign = varga.cusps[0].sign;
    final karakasPerHouse = _karakasPerHouse(varga);
    final moonHouse = houseFrom(lagnaSign, varga.moon.sign);
    const eligible = [
      Body.mars,
      Body.mercury,
      Body.jupiter,
      Body.venus,
      Body.saturn,
    ];

    final secondHouse = (moonHouse % 12) + 1;
    final twelfthHouse = ((moonHouse - 2 + 12) % 12) + 1;

    final inSecond = (karakasPerHouse[secondHouse] ?? const [])
        .where(eligible.contains)
        .toList();
    final inTwelfth = (karakasPerHouse[twelfthHouse] ?? const [])
        .where(eligible.contains)
        .toList();

    final hasSunapha = inSecond.isNotEmpty;
    final hasAnapha = inTwelfth.isNotEmpty;

    return [
      SolarLunarYoga(
        name: 'Sunapha',
        category: 'Lunar',
        planets: inSecond,
        present: hasSunapha,
      ),
      SolarLunarYoga(
        name: 'Anapha',
        category: 'Lunar',
        planets: inTwelfth,
        present: hasAnapha,
      ),
      SolarLunarYoga(
        name: 'Durudhara',
        category: 'Lunar',
        planets: [...inSecond, ...inTwelfth],
        present: hasSunapha && hasAnapha,
      ),
      SolarLunarYoga(
        name: 'Kemadruma',
        category: 'Lunar',
        planets: const [],
        present: !hasSunapha && !hasAnapha,
      ),
    ];
  }

  // ── Shared solar/lunar helper ────────────────────────────────────────────────

  static List<SolarLunarYoga> _solarLunarYogas({
    required Map<int, List<Body>> karakasPerHouse,
    required int refHouse,
    required String category,
    required String secondName,
    required String twelfthName,
    required String bothName,
  }) {
    const eligible = [
      Body.mars,
      Body.mercury,
      Body.jupiter,
      Body.venus,
      Body.saturn,
    ];

    final secondHouse = (refHouse % 12) + 1;
    final twelfthHouse = ((refHouse - 2 + 12) % 12) + 1;

    final inSecond = (karakasPerHouse[secondHouse] ?? const [])
        .where(eligible.contains)
        .toList();
    final inTwelfth = (karakasPerHouse[twelfthHouse] ?? const [])
        .where(eligible.contains)
        .toList();

    final hasSecond = inSecond.isNotEmpty;
    final hasTwelfth = inTwelfth.isNotEmpty;

    return [
      SolarLunarYoga(
        name: secondName,
        category: category,
        planets: inSecond,
        present: hasSecond,
      ),
      SolarLunarYoga(
        name: twelfthName,
        category: category,
        planets: inTwelfth,
        present: hasTwelfth,
      ),
      SolarLunarYoga(
        name: bothName,
        category: category,
        planets: [...inSecond, ...inTwelfth],
        present: hasSecond && hasTwelfth,
      ),
    ];
  }
}
