// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_core/arrow_core.dart';
import 'package:test/test.dart';

import 'helpers/stub_snapshot.dart';

void main() {
  final snapshot = stubSnapshot();
  const config = CalcConfig();

  group('Chart', () {
    test('rashi access gives correct sign', () {
      final chart = Chart(snapshot, config);
      // Sun at 45° with aditya: signIndex = (1+1)%12 = 2, sign = 3
      expect(chart.rashi.sun.sign, 3);
    });

    test('sign occupants are correct', () {
      final chart = Chart(snapshot, config);
      // Find which sign Sun is in, check it appears in that sign's planets
      final sunSign = chart.rashi.sun.sign;
      final sign = chart.rashi.signs[sunSign]!;
      expect(sign.planets.any((p) => p.body == Body.sun), isTrue);
    });

    test('signOf returns correct Sign', () {
      final chart = Chart(snapshot, config);
      final marsSign = chart.rashi.signOf(chart.rashi.mars);
      expect(marsSign.number, chart.rashi.mars.sign);
    });

    test('sign has lord, element, quality, gender', () {
      final chart = Chart(snapshot, config);
      final sign1 = chart.rashi.signs[1]!;
      expect(sign1.lord, Body.mars); // Aries
      expect(sign1.element, Element.fire);
      expect(sign1.quality, Quality.cardinal);
      expect(sign1.gender, Gender.male);
    });

    test('nakshatra occupants are correct', () {
      final chart = Chart(snapshot, config);
      final moonNak = chart.rashi.moon.nakshatra;
      final nak = chart.rashi.nakshatras[moonNak]!;
      expect(nak.planets.any((p) => p.body == Body.moon), isTrue);
    });

    test('nakshatraOf returns correct Nakshatra', () {
      final chart = Chart(snapshot, config);
      final moonNak = chart.rashi.nakshatraOf(chart.rashi.moon);
      expect(moonNak.number, chart.rashi.moon.nakshatra);
    });

    test('nakshatra has lord and deity', () {
      final chart = Chart(snapshot, config);
      final nak1 = chart.rashi.nakshatras[1]!;
      expect(nak1.lord, isNotNull);
      expect(nak1.deity, isNotEmpty);
    });

    test('varga access gives different signs', () {
      final chart = Chart(snapshot, config);
      final rashiSign = chart.rashi.sun.sign;
      final navSign = chart.varga(VargaType.navamsha).sun.sign;
      // Navamsha sign should differ from rashi for Sun at 45°
      expect(navSign, isNot(equals(rashiSign)));
    });

    test('varga caching returns same instance', () {
      final chart = Chart(snapshot, config);
      final nav1 = chart.varga(VargaType.navamsha);
      final nav2 = chart.varga(VargaType.navamsha);
      expect(identical(nav1, nav2), isTrue);
    });

    test('rashi is in varga cache', () {
      final chart = Chart(snapshot, config);
      final fromCache = chart.varga(VargaType.rashi);
      expect(identical(fromCache, chart.rashi), isTrue);
    });

    test('all 12 signs exist', () {
      final chart = Chart(snapshot, config);
      for (var s = 1; s <= 12; s++) {
        expect(chart.rashi.signs.containsKey(s), isTrue);
      }
    });

    test('all 27 nakshatras exist', () {
      final chart = Chart(snapshot, config);
      for (var n = 1; n <= 27; n++) {
        expect(chart.rashi.nakshatras.containsKey(n), isTrue);
      }
    });

    test('planet identity is consistent', () {
      final chart = Chart(snapshot, config);
      final sunFromRashi = chart.rashi.sun;
      final sunSign = chart.rashi.signs[sunFromRashi.sign]!;
      final sunFromSign = sunSign.planets.firstWhere((p) => p.body == Body.sun);
      expect(identical(sunFromRashi, sunFromSign), isTrue);
    });

    test('named planet accessors work', () {
      final chart = Chart(snapshot, config);
      expect(chart.rashi.sun.body, Body.sun);
      expect(chart.rashi.moon.body, Body.moon);
      expect(chart.rashi.mars.body, Body.mars);
      expect(chart.rashi.mercury.body, Body.mercury);
      expect(chart.rashi.jupiter.body, Body.jupiter);
      expect(chart.rashi.venus.body, Body.venus);
      expect(chart.rashi.saturn.body, Body.saturn);
      expect(chart.rashi.rahu.body, Body.rahu);
      expect(chart.rashi.ketu.body, Body.ketu);
    });

    test('karakas are accessible from varga', () {
      final chart = Chart(snapshot, config);
      final karakas = chart.rashi.karakas;
      // 7 karaka-eligible bodies (Sun through Saturn, no Rahu/Ketu)
      expect(karakas.length, 7);
    });

    test('retrograde detection through chart', () {
      final chart = Chart(snapshot, config);
      expect(chart.rashi.mars.isRetrograde, isTrue);
      expect(chart.rashi.sun.isRetrograde, isFalse);
    });
  });

  group('Typed accessors on Chart', () {
    test('chart.sun returns Karaka', () {
      final chart = Chart(snapshot, config);
      expect(chart.sun, isA<Karaka>());
      expect(chart.sun.body, Body.sun);
      expect(chart.sun.sign, chart.rashi.sun.sign);
    });

    test('chart.rahu returns Planet', () {
      final chart = Chart(snapshot, config);
      expect(chart.rahu, isA<Planet>());
      expect(chart.rahu.body, Body.rahu);
    });

    test('chart.planets includes all bodies', () {
      final chart = Chart(snapshot, config);
      expect(chart.planets.length, 9);
      final bodies = chart.planets.map((p) => p.body).toSet();
      expect(bodies, containsAll([Body.sun, Body.rahu, Body.ketu]));
    });

    test('chart.karakas has 7 entries', () {
      final chart = Chart(snapshot, config);
      expect(chart.karakas.length, 7);
      final bodies = chart.karakas.map((k) => k.body).toSet();
      expect(bodies.contains(Body.rahu), isFalse);
    });

    test('chart.grahas has 9 entries', () {
      final chart = Chart(snapshot, config);
      expect(chart.grahas.length, 9);
      final bodies = chart.grahas.map((g) => g.body).toSet();
      expect(bodies, containsAll([Body.sun, Body.rahu, Body.ketu]));
    });

    test('chart.cusps has 12 entries', () {
      final chart = Chart(snapshot, config);
      expect(chart.cusps.length, 12);
      expect(chart.cusps[0].house, 1);
      expect(chart.cusps[11].house, 12);
    });

    test('chart.cusp(n) returns correct house', () {
      final chart = Chart(snapshot, config);
      expect(chart.cusp(1).house, 1);
      expect(chart.cusp(7).house, 7);
    });

    test('chart.ascendant and chart.mc', () {
      final chart = Chart(snapshot, config);
      expect(chart.ascendant, 10.0);
      expect(chart.mc, 280.0);
    });
  });

  group('Varga typed accessors', () {
    test('varga.sun returns Karaka', () {
      final chart = Chart(snapshot, config);
      final nav = chart.varga(VargaType.navamsha);
      expect(nav.sun, isA<Karaka>());
      expect(nav.sun.body, Body.sun);
    });

    test('varga.rahu returns Planet', () {
      final chart = Chart(snapshot, config);
      expect(chart.rashi.rahu, isA<Planet>());
      expect(chart.rashi.rahu.body, Body.rahu);
    });

    test('varga.cusps retained', () {
      final chart = Chart(snapshot, config);
      expect(chart.rashi.cusps.length, 12);
    });
  });

  group('Karaka dignity', () {
    test('chart.sun.dignity returns a DignityType', () {
      final chart = Chart(snapshot, config);
      final dignity = chart.sun.dignity;
      expect(dignity, isA<DignityType>());
    });

    test('Sun at 45° (Taurus in zodiac) dignity computes', () {
      // Use zodiac circle for simpler sign math
      const zodiacConfig = CalcConfig(circle: Circle.zodiac);
      final chart = Chart(snapshot, zodiacConfig);
      // Sun at 45° zodiac = 15° Taurus (sign 2). Lord Venus at 30° = 0° Taurus.
      final dignity = chart.sun.dignity;
      expect(dignity, isNotNull);
    });
  });

  group('Karaka combustion', () {
    test('Mercury near Sun is combust through chart', () {
      final chart = Chart(snapshot, config);
      // Mercury at 55°, Sun at 45° → 10° apart < 14° orb → combust
      expect(chart.mercury.isCombust, isTrue);
    });

    test('Jupiter far from Sun is not combust', () {
      final chart = Chart(snapshot, config);
      // Jupiter at 280°, Sun at 45° → far apart → not combust
      expect(chart.jupiter.isCombust, isFalse);
    });

    test('Sun is never combust', () {
      final chart = Chart(snapshot, config);
      expect(chart.sun.isCombust, isFalse);
    });
  });

  group('Cusp nakshatra', () {
    test('cusp.nakshatra returns valid range', () {
      final chart = Chart(snapshot, config);
      for (final cusp in chart.cusps) {
        expect(cusp.nakshatra, inInclusiveRange(1, 27));
      }
    });

    test('cusp.pada returns valid range', () {
      final chart = Chart(snapshot, config);
      for (final cusp in chart.cusps) {
        expect(cusp.pada, inInclusiveRange(1, 4));
      }
    });
  });
}
