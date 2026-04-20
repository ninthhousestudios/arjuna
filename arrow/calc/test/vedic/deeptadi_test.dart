import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

/// Minimal `Map` of 9 grahas at longitudes that keep each body far from
/// the others (no conjunctions, no aspects) so the per-priority steps in
/// Deeptadi can be tested in isolation.
const Map<Body, double> _scattered = {
  Body.sun: 0.0,
  Body.moon: 40.0,
  Body.mars: 80.0,
  Body.mercury: 120.0,
  Body.jupiter: 160.0,
  Body.venus: 200.0,
  Body.saturn: 240.0,
  Body.rahu: 280.0,
  Body.ketu: 100.0,
};

void main() {
  group('Deeptadi.of — priority cascade', () {
    test('step 1 — exalted → deepta', () {
      expect(
        Deeptadi.of(
          body: Body.jupiter,
          dignity: DignityType.exalted,
          eclipticLongitude: 160.0,
          isRetrograde: false,
          sunLongitude: 0.0,
          grahaLongitudes: _scattered,
        ),
        DeeptadiState.deepta,
      );
    });

    test('step 2 — ownSign → swastha', () {
      expect(
        Deeptadi.of(
          body: Body.jupiter,
          dignity: DignityType.ownSign,
          eclipticLongitude: 160.0,
          isRetrograde: false,
          sunLongitude: 0.0,
          grahaLongitudes: _scattered,
        ),
        DeeptadiState.swastha,
      );
    });

    test('step 3 — friend / greatFriend → mudita', () {
      for (final d in [DignityType.friend, DignityType.greatFriend]) {
        expect(
          Deeptadi.of(
            body: Body.jupiter,
            dignity: d,
            eclipticLongitude: 160.0,
            isRetrograde: false,
            sunLongitude: 0.0,
            grahaLongitudes: _scattered,
          ),
          DeeptadiState.mudita,
        );
      }
    });

    test('step 4 — benefic navamsa → shanta', () {
      // lon=0 → navamsa sign 1 (not benefic). lon=10 → navamsa sign 4 (benefic).
      expect(
        Deeptadi.of(
          body: Body.venus,
          dignity: DignityType.neutral,
          eclipticLongitude: 10.0,
          isRetrograde: false,
          sunLongitude: 180.0,
          grahaLongitudes: {
            ..._scattered,
            Body.venus: 10.0,
          },
        ),
        DeeptadiState.shanta,
      );
    });

    test('step 5 — retrograde → shakta (when earlier steps fail)', () {
      // Non-benefic navamsa: pick sign 1 (lon 0–3.33° → nav sign 1).
      expect(
        Deeptadi.of(
          body: Body.jupiter,
          dignity: DignityType.neutral,
          eclipticLongitude: 1.0,
          isRetrograde: true,
          sunLongitude: 180.0,
          grahaLongitudes: {
            ..._scattered,
            Body.jupiter: 1.0,
            // Keep other malefics far from Jupiter so no aspect fires.
          },
        ),
        DeeptadiState.shakta,
      );
    });

    test('step 7 — debilitated (no earlier trigger) → deena', () {
      expect(
        Deeptadi.of(
          body: Body.jupiter,
          dignity: DignityType.debilitated,
          eclipticLongitude: 1.0,
          isRetrograde: false,
          sunLongitude: 180.0,
          grahaLongitudes: {
            ..._scattered,
            Body.jupiter: 1.0,
            // Sun, Mars, Saturn, Rahu, Ketu all far from Jupiter (lon 1°).
            Body.sun: 180.0,
            Body.mars: 220.0,
            Body.saturn: 100.0,
            Body.rahu: 95.0,
            Body.ketu: 275.0,
          },
        ),
        DeeptadiState.deena,
      );
    });

    test('step 9 — enemy sign → khala', () {
      expect(
        Deeptadi.of(
          body: Body.jupiter,
          dignity: DignityType.greatEnemy,
          eclipticLongitude: 1.0,
          isRetrograde: false,
          sunLongitude: 180.0,
          grahaLongitudes: {
            ..._scattered,
            // Place every malefic behind Jupiter within ≤30° forward gap
            // (sign 12), so Parashara diff from malefic → Jupiter is ≤30 and
            // no aspect fires.
            Body.jupiter: 1.0,
            Body.sun: 331.0,
            Body.mars: 335.0,
            Body.saturn: 340.0,
            Body.rahu: 345.0,
            Body.ketu: 350.0,
          },
        ),
        DeeptadiState.khala,
      );
    });
  });
}
