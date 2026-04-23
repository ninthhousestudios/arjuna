import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_calc/src/vedic/vimshottari.dart';
import 'package:test/test.dart';

// J2000.0 = JD 2451545.0 — a convenient reference epoch.
const _j2000 = 2451545.0;

void main() {
  group('DashaYearLength', () {
    test('saura days', () => expect(DashaYearLength.saura.days, 365.2422));
    test('savana days', () => expect(DashaYearLength.savana.days, 360.0));
    test('chandra days', () => expect(DashaYearLength.chandra.days, 364.2888));
  });

  group('Vimshottari.periodDuration', () {
    test('Sun mahadasha = 6 saura years', () {
      // Sun is index 2 in _lordOrder / _dashaYears (years=6).
      const sunIdx = 2;
      final days = Vimshottari.periodDuration([sunIdx], DashaYearLength.saura.days);
      expect(days, closeTo(6 * 365.2422, 1e-9));
    });

    test('Venus mahadasha = 20 saura years', () {
      const venusIdx = 1;
      final days =
          Vimshottari.periodDuration([venusIdx], DashaYearLength.saura.days);
      expect(days, closeTo(20 * 365.2422, 1e-9));
    });

    test('Sun-Moon antardasha = 6*10/120 saura years', () {
      // Sun=idx2 (6yr), Moon=idx3 (10yr). Antardasha = 6*10/120 yr.
      const sunIdx = 2;
      const moonIdx = 3;
      final days =
          Vimshottari.periodDuration([sunIdx, moonIdx], DashaYearLength.saura.days);
      final expectedYears = 6.0 * 10.0 / 120.0;
      expect(days, closeTo(expectedYears * 365.2422, 1e-9));
    });

    test('Sun-Moon-Mars pratyantar = 6*10*7/120^2 saura years', () {
      const sunIdx = 2;
      const moonIdx = 3;
      const marsIdx = 4;
      final days = Vimshottari.periodDuration(
          [sunIdx, moonIdx, marsIdx], DashaYearLength.saura.days);
      final expectedYears = 6.0 * 10.0 * 7.0 / (120.0 * 120.0);
      expect(days, closeTo(expectedYears * 365.2422, 1e-9));
    });

    test('savana year length changes result', () {
      const sunIdx = 2;
      final saura =
          Vimshottari.periodDuration([sunIdx], DashaYearLength.saura.days);
      final savana =
          Vimshottari.periodDuration([sunIdx], DashaYearLength.savana.days);
      expect(savana, closeTo(6 * 360.0, 1e-9));
      expect(savana, isNot(equals(saura)));
    });
  });

  group('Vimshottari.seed', () {
    test('Moon at nakshatra boundary → elapsedFraction=0, dashaStartJd=birthJd',
        () {
      // Nakshatra 1 starts at 0°. If Moon is exactly at 0°, elapsed=0,
      // so dashaStartJd should equal birthJd.
      const moonLon = 0.0;
      const birthJd = _j2000;
      final s = Vimshottari.seed(moonLon, birthJd, DashaYearLength.saura.days);
      expect(s.firstIndex, 0); // nindex=0, 0%9=0 → Ketu
      expect(s.dashaStartJd, closeTo(birthJd, 1e-9));
    });

    test('Moon at start of nakshatra 10 (index 9) → firstIndex=0 (Ketu)', () {
      // Nakshatra 10 (Magha) starts at 9 * (360/27) = 120°.
      final nakSize = 360.0 / 27.0;
      final moonLon = 9 * nakSize; // exactly start of nak 10
      final s =
          Vimshottari.seed(moonLon, _j2000, DashaYearLength.saura.days);
      // nindex=9, 9%9=0 → Ketu
      expect(s.firstIndex, 0);
      expect(s.dashaStartJd, closeTo(_j2000, 1e-9));
    });

    test('Moon mid-Sun nakshatra (nak 3, index 2) → firstIndex=2 (Sun)', () {
      // Nakshatra 3 (Krittika) is index 2 (0-based). Lord is Sun.
      // nindex=2, 2%9=2 → Sun (index 2 in _lordOrder).
      final nakSize = 360.0 / 27.0;
      // Put Moon halfway through nak 3
      final moonLon = 2 * nakSize + nakSize / 2.0;
      final s =
          Vimshottari.seed(moonLon, _j2000, DashaYearLength.saura.days);
      expect(s.firstIndex, 2); // Sun
      // Half of Sun's 6 years elapsed → dashaStartJd is 3 saura years before birth
      final expectedStart = _j2000 - 3.0 * 365.2422;
      expect(s.dashaStartJd, closeTo(expectedStart, 1e-6));
    });

    test('Moon at 10° sidereal → correct firstIndex and dashaStartJd', () {
      // 10° falls in nakshatra index 0 (Ashwini, 0-13.33°). Lord=Ketu (idx 0).
      // elapsed = 10 - 0 = 10°, fraction = 10 / (360/27) ≈ 0.75
      final nakSize = 360.0 / 27.0;
      const moonLon = 10.0;
      const birthJd = _j2000;
      final s = Vimshottari.seed(moonLon, birthJd, DashaYearLength.saura.days);
      expect(s.firstIndex, 0); // Ketu
      final fraction = 10.0 / nakSize;
      final yearsElapsed = 7.0 * fraction; // Ketu = 7 years
      final expectedStart = birthJd - yearsElapsed * 365.2422;
      expect(s.dashaStartJd, closeTo(expectedStart, 1e-6));
    });
  });

  group('Vimshottari.currentDasha', () {
    // Birth: Moon at 10° sidereal. birthJd = J2000.
    // First dasha: Ketu (7yr). Seed start = birthJd - yearsElapsed*saura.
    // We'll ask for nowJd = birthJd + 1 year (still in Ketu mahadasha).

    test('active mahadasha at birthJd+1yr is Ketu', () {
      const moonLon = 10.0;
      const birthJd = _j2000;
      final nowJd = birthJd + 365.2422; // 1 year after birth
      final periods = Vimshottari.currentDasha(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        nowJd: nowJd,
        levels: 1,
      );
      expect(periods.length, 1);
      expect(periods[0].lords, [Body.ketu]);
    });

    test('returns 3 periods at levels=3', () {
      const moonLon = 10.0;
      const birthJd = _j2000;
      final nowJd = birthJd + 365.2422;
      final periods = Vimshottari.currentDasha(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        nowJd: nowJd,
        levels: 3,
      );
      expect(periods.length, 3);
      // Each successive period is a sub-period of the previous
      expect(periods[0].lords.length, 1);
      expect(periods[1].lords.length, 2);
      expect(periods[2].lords.length, 3);
    });

    test('lord chain is consistent across levels', () {
      const moonLon = 10.0;
      const birthJd = _j2000;
      final nowJd = birthJd + 365.2422;
      final periods = Vimshottari.currentDasha(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        nowJd: nowJd,
        levels: 3,
      );
      // Each level's lords list is a prefix extension of the previous
      expect(periods[1].lords.take(1).toList(), periods[0].lords);
      expect(periods[2].lords.take(2).toList(), periods[1].lords);
    });

    test('active period contains nowJd', () {
      const moonLon = 10.0;
      const birthJd = _j2000;
      final nowJd = birthJd + 365.2422;
      final periods = Vimshottari.currentDasha(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        nowJd: nowJd,
        levels: 3,
      );
      for (final p in periods) {
        expect(nowJd, greaterThanOrEqualTo(p.startJd));
        expect(nowJd, lessThan(p.endJd));
      }
    });

    test('rolls into Venus mahadasha after Ketu ends', () {
      // Moon at 10° → Ketu mahadasha. Seed start = birthJd - yearsElapsed*saura.
      // Ketu runs from dashaStartJd for 7*saura days.
      final nakSize = 360.0 / 27.0;
      const moonLon = 10.0;
      const birthJd = _j2000;
      final fraction = 10.0 / nakSize;
      final yearsElapsed = 7.0 * fraction;
      final dashaStart = birthJd - yearsElapsed * 365.2422;
      // Venus starts after Ketu's full 7 years
      final venusStart = dashaStart + 7.0 * 365.2422;
      final nowJd = venusStart + 365.2422; // 1yr into Venus
      final periods = Vimshottari.currentDasha(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        nowJd: nowJd,
        levels: 1,
      );
      expect(periods[0].lords[0], Body.venus);
    });
  });

  group('Vimshottari sub-dasha sequencing', () {
    // Within a mahadasha, the first antardasha lord = same as mahadasha lord,
    // then cycles through all 9 in Vimshottari order.
    // libaditya: at level 1, dlist=[firstIndex, parentLord], first sub = parentLord.

    test('Sun mahadasha: first antardasha is Sun', () {
      // Put Moon at start of Sun nakshatra (nak 3, index 2) so firstIndex=2=Sun,
      // and elapsedFraction=0 so dashaStartJd=birthJd.
      final nakSize = 360.0 / 27.0;
      final moonLon = 2 * nakSize; // exact start of nak index 2 (Sun)
      const birthJd = _j2000;
      // Ask for nowJd right at birth — we're at the very start of Sun mahadasha
      final nowJd = birthJd + 1.0; // 1 day in
      final periods = Vimshottari.currentDasha(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        nowJd: nowJd,
        levels: 2,
      );
      expect(periods[0].lords[0], Body.sun); // mahadasha = Sun
      expect(periods[1].lords[1], Body.sun); // first antardasha = Sun
    });

    test('Sun mahadasha: sequence of antardashas cycles through 9 lords', () {
      // Build the full tree at levels=2, check the 9 antardashas under Sun maha.
      // Sun mahadasha starts when Moon is exactly at start of Sun nakshatra.
      final nakSize = 360.0 / 27.0;
      final moonLon = 2 * nakSize;
      const birthJd = _j2000;
      final tree = Vimshottari.fullTree(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        levels: 2,
      );
      // First mahadasha is Sun. Collect its sub-periods (lords.length==2, lords[0]==sun).
      final sunSubs = tree
          .where((p) => p.lords.length == 2 && p.lords[0] == Body.sun)
          .toList();
      expect(sunSubs.length, 9);
      // libaditya: sub-sequence starts from parent lord (Sun=idx2), then cycles:
      // Sun, Moon, Mars, Rahu, Jupiter, Saturn, Mercury, Ketu, Venus
      const expectedOrder = [
        Body.sun,
        Body.moon,
        Body.mars,
        Body.rahu,
        Body.jupiter,
        Body.saturn,
        Body.mercury,
        Body.ketu,
        Body.venus,
      ];
      for (var i = 0; i < 9; i++) {
        expect(sunSubs[i].lords[1], expectedOrder[i],
            reason: 'antardasha $i should be ${expectedOrder[i].name}');
      }
    });
  });

  group('Vimshottari.specificPeriod', () {
    test('Sun mahadasha duration matches periodDuration', () {
      const moonLon = 10.0;
      const birthJd = _j2000;
      final period = Vimshottari.specificPeriod(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        lords: [Body.sun],
      );
      expect(period.lords, [Body.sun]);
      expect(period.durationDays, closeTo(6 * 365.2422, 1e-6));
    });

    test('specificPeriod start matches currentDasha for same nowJd', () {
      const moonLon = 10.0;
      const birthJd = _j2000;
      // Get the active mahadasha just after birth
      final nowJd = birthJd + 1.0;
      final current = Vimshottari.currentDasha(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        nowJd: nowJd,
        levels: 1,
      );
      final activeLord = current[0].lords[0];
      final specific = Vimshottari.specificPeriod(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        lords: [activeLord],
      );
      expect(specific.startJd, closeTo(current[0].startJd, 1e-6));
      expect(specific.durationDays, closeTo(current[0].durationDays, 1e-6));
    });
  });

  group('Vimshottari.fullTree', () {
    test('levels=1 produces exactly 9 mahadashas', () {
      const moonLon = 10.0;
      const birthJd = _j2000;
      final tree = Vimshottari.fullTree(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        levels: 1,
      );
      expect(tree.length, 9);
      for (final p in tree) {
        expect(p.lords.length, 1);
      }
    });

    test('9 mahadasha durations sum to 120 saura years', () {
      const moonLon = 0.0; // exact boundary → no partial first period
      const birthJd = _j2000;
      final tree = Vimshottari.fullTree(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        levels: 1,
      );
      final totalDays = tree.fold<double>(0.0, (s, p) => s + p.durationDays);
      expect(totalDays, closeTo(120 * 365.2422, 1e-6));
    });

    test('9 mahadasha durations sum to 120 savana years', () {
      const moonLon = 0.0;
      const birthJd = _j2000;
      final tree = Vimshottari.fullTree(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        levels: 1,
        yrlen: DashaYearLength.savana,
      );
      final totalDays = tree.fold<double>(0.0, (s, p) => s + p.durationDays);
      expect(totalDays, closeTo(120 * 360.0, 1e-6));
    });

    test('levels=2 produces 9 + 81 = 90 periods', () {
      const moonLon = 0.0;
      const birthJd = _j2000;
      final tree = Vimshottari.fullTree(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        levels: 2,
      );
      // 9 mahadashas + 9*9 antardashas
      expect(tree.length, 9 + 9 * 9);
    });

    test('antardasha durations within each mahadasha sum to that mahadasha', () {
      const moonLon = 0.0;
      const birthJd = _j2000;
      final tree = Vimshottari.fullTree(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        levels: 2,
      );
      final mahadashas = tree.where((p) => p.lords.length == 1).toList();
      for (final maha in mahadashas) {
        final subs = tree
            .where((p) => p.lords.length == 2 && p.lords[0] == maha.lords[0])
            .toList();
        expect(subs.length, 9);
        final subTotal =
            subs.fold<double>(0.0, (s, p) => s + p.durationDays);
        expect(subTotal, closeTo(maha.durationDays, 1e-6),
            reason: '${maha.lords[0].name} sub-periods should sum to mahadasha');
      }
    });

    test('mahadashas cover the full 9-lord cycle starting from seed lord', () {
      // Moon at 0° → firstIndex=0 (Ketu). Mahadasha sequence should be:
      // Ketu, Venus, Sun, Moon, Mars, Rahu, Jupiter, Saturn, Mercury
      const moonLon = 0.0;
      const birthJd = _j2000;
      final tree = Vimshottari.fullTree(
        moonSiderealLon: moonLon,
        birthJd: birthJd,
        levels: 1,
      );
      const expectedOrder = [
        Body.ketu,
        Body.venus,
        Body.sun,
        Body.moon,
        Body.mars,
        Body.rahu,
        Body.jupiter,
        Body.saturn,
        Body.mercury,
      ];
      for (var i = 0; i < 9; i++) {
        expect(tree[i].lords[0], expectedOrder[i]);
      }
    });
  });
}
