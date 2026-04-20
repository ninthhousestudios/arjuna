import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:test/test.dart';

PhenoData _pheno({
  double phaseAngle = 90,
  double phase = 0.5,
  required double elongation,
}) =>
    PhenoData(
      phaseAngle: phaseAngle,
      phase: phase,
      elongation: elongation,
      apparentDiameter: 0,
      apparentMagnitude: 0,
    );

void main() {
  group('directionOf', () {
    test('direct when speed clearly positive', () {
      expect(directionOf(Body.mars, 0.524), Direction.direct);
    });

    test('retrograde when speed clearly negative', () {
      expect(directionOf(Body.mars, -0.4), Direction.retrograde);
    });

    test('stationary when |speed| <= stationThreshold', () {
      final t = stationThreshold[Body.mars]!;
      expect(directionOf(Body.mars, t), Direction.stationary);
      expect(directionOf(Body.mars, -t), Direction.stationary);
      expect(directionOf(Body.mars, 0.0), Direction.stationary);
    });

    test('Sun/Moon classify correctly (never retrograde in reality)', () {
      expect(directionOf(Body.sun, 0.9856), Direction.direct);
      expect(directionOf(Body.moon, 13.1764), Direction.direct);
    });

    test('outer planets — small stationThreshold still applies', () {
      final t = stationThreshold[Body.pluto]!;
      expect(directionOf(Body.pluto, t / 2), Direction.stationary);
      expect(directionOf(Body.pluto, t * 2), Direction.direct);
      expect(directionOf(Body.pluto, -t * 2), Direction.retrograde);
    });
  });

  group('classifySpeed', () {
    test('mean speed → mean', () {
      final m = meanDailyMotion[Body.mars]!;
      expect(classifySpeed(Body.mars, m), SpeedClass.mean);
      expect(classifySpeed(Body.mars, -m), SpeedClass.mean);
    });

    test('slightly below mean → still mean (within 0.8x band)', () {
      final m = meanDailyMotion[Body.mars]!;
      expect(classifySpeed(Body.mars, m * 0.9), SpeedClass.mean);
    });

    test('below 0.8x mean → slow', () {
      final m = meanDailyMotion[Body.jupiter]!;
      expect(classifySpeed(Body.jupiter, m * 0.5), SpeedClass.slow);
    });

    test('above 1.2x mean → fast', () {
      final m = meanDailyMotion[Body.mercury]!;
      expect(classifySpeed(Body.mercury, m * 1.5), SpeedClass.fast);
    });

    test('|speed| <= stationThreshold → stationary (even if < slow band)', () {
      final t = stationThreshold[Body.saturn]!;
      expect(classifySpeed(Body.saturn, t), SpeedClass.stationary);
      expect(classifySpeed(Body.saturn, -t), SpeedClass.stationary);
    });

    test('negative magnitudes use |speed|', () {
      final m = meanDailyMotion[Body.jupiter]!;
      expect(classifySpeed(Body.jupiter, -m), SpeedClass.mean);
      expect(classifySpeed(Body.jupiter, -m * 1.5), SpeedClass.fast);
    });

    test('boundary cases — exactly at 0.8x and 1.2x are "mean"', () {
      final m = meanDailyMotion[Body.venus]!;
      expect(classifySpeed(Body.venus, m * 0.8), SpeedClass.mean);
      expect(classifySpeed(Body.venus, m * 1.2), SpeedClass.mean);
    });
  });

  group('ElongationCategory.of — boundary cases', () {
    test('0° → conjunction', () {
      expect(ElongationCategory.of(0), ElongationCategory.conjunction);
    });
    test('4.99° → conjunction', () {
      expect(ElongationCategory.of(4.99), ElongationCategory.conjunction);
    });
    test('5° → nearConjunction', () {
      expect(ElongationCategory.of(5), ElongationCategory.nearConjunction);
    });
    test('19.99° → nearConjunction', () {
      expect(ElongationCategory.of(19.99), ElongationCategory.nearConjunction);
    });
    test('20° → earlyElongation', () {
      expect(ElongationCategory.of(20), ElongationCategory.earlyElongation);
    });
    test('59.99° → earlyElongation', () {
      expect(ElongationCategory.of(59.99), ElongationCategory.earlyElongation);
    });
    test('60° → quadrature', () {
      expect(ElongationCategory.of(60), ElongationCategory.quadrature);
    });
    test('119.99° → quadrature', () {
      expect(ElongationCategory.of(119.99), ElongationCategory.quadrature);
    });
    test('120° → gibbous', () {
      expect(ElongationCategory.of(120), ElongationCategory.gibbous);
    });
    test('149.99° → gibbous', () {
      expect(ElongationCategory.of(149.99), ElongationCategory.gibbous);
    });
    test('150° → opposition', () {
      expect(ElongationCategory.of(150), ElongationCategory.opposition);
    });
    test('180° → opposition', () {
      expect(ElongationCategory.of(180), ElongationCategory.opposition);
    });
    test('abs() handles negative input', () {
      expect(ElongationCategory.of(-45), ElongationCategory.earlyElongation);
    });
  });

  group('SynodicState.from', () {
    SynodicState build(Body body, double bodyLong, double sunLong,
            {double elongation = 90}) =>
        SynodicState.from(
          body: body,
          bodyLongitude: bodyLong,
          sunLongitude: sunLong,
          pheno: _pheno(elongation: elongation),
        );

    test('category derives from elongation', () {
      final s = build(Body.moon, 100, 10, elongation: 90);
      expect(s.category, ElongationCategory.quadrature);
    });

    group('Moon — waxing iff east of Sun (Δλ ∈ (0°, 180°))', () {
      test('first quarter (Moon 90° east) → waxing', () {
        expect(build(Body.moon, 100, 10).isWaxing, isTrue);
      });
      test('last quarter (Moon 90° west / 270° east) → waning', () {
        expect(build(Body.moon, 10, 100).isWaxing, isFalse);
      });
      test('new Moon (Δλ = 0) → not waxing', () {
        expect(build(Body.moon, 50, 50).isWaxing, isFalse);
      });
      test('full Moon (Δλ = 180) → not waxing', () {
        expect(build(Body.moon, 230, 50).isWaxing, isFalse);
      });
      test('handles longitude wrap (sun=350, moon=10 → Δλ=20, waxing)', () {
        expect(build(Body.moon, 10, 350).isWaxing, isTrue);
      });
    });

    group('Inner planets — waxing iff west of Sun (Δλ ∈ (180°, 360°))', () {
      test('Venus morning star (Δλ=270, west of Sun) → waxing', () {
        expect(build(Body.venus, 280, 10).isWaxing, isTrue);
      });
      test('Venus evening star (Δλ=45, east of Sun) → waning', () {
        expect(build(Body.venus, 55, 10).isWaxing, isFalse);
      });
      test('Mercury morning star → waxing', () {
        expect(build(Body.mercury, 350, 10).isWaxing, isTrue);
      });
      test('Mercury evening star → waning', () {
        expect(build(Body.mercury, 25, 10).isWaxing, isFalse);
      });
    });

    group('Outer planets and Sun — isWaxing is null (n/a)', () {
      for (final body in [
        Body.sun,
        Body.mars,
        Body.jupiter,
        Body.saturn,
        Body.uranus,
        Body.neptune,
        Body.pluto,
        Body.chiron,
      ]) {
        test('${body.name} → isWaxing null', () {
          expect(build(body, 100, 10).isWaxing, isNull);
        });
      }
    });

    test('pheno pass-through', () {
      final p = _pheno(elongation: 30, phaseAngle: 45);
      final s = SynodicState.from(
        body: Body.moon,
        bodyLongitude: 100,
        sunLongitude: 10,
        pheno: p,
      );
      expect(identical(s.pheno, p), isTrue);
    });
  });
}
