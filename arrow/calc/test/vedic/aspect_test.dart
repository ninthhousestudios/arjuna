import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  group('Aspect.isConjunction', () {
    test('same sign = conjunction', () {
      expect(Aspect.isConjunction(5.0, 25.0), isTrue); // both Aries
      expect(Aspect.isConjunction(100.0, 115.0), isTrue); // both Cancer
    });

    test('different signs = not conjunction', () {
      expect(Aspect.isConjunction(29.0, 31.0), isFalse);
      expect(Aspect.isConjunction(0.0, 30.0), isFalse);
      expect(Aspect.isConjunction(359.0, 1.0), isFalse);
    });

    test('wraps around 360', () {
      expect(Aspect.isConjunction(5.0, 365.0), isTrue);
    });
  });

  group('Aspect.strength — base (Sun)', () {
    // libaditya planets.py:391-422. fromLon=0 → toLon=diff.
    double s(double diff) => Aspect.strength(Body.sun, 0.0, diff);
    test('no aspect at 0/30/150/300', () {
      expect(s(30.0), 0.0); // diff<=30
      expect(s(150.0), 0.0); // (120,150] → 150-150=0
      expect(s(300.0), 0.0); // diff>=300
    });
    test('piecewise values', () {
      expect(s(31.0), closeTo(0.5, 1e-9));
      expect(s(60.0), closeTo(15.0, 1e-9));
      expect(s(61.0), closeTo(16.0, 1e-9));
      expect(s(90.0), closeTo(45.0, 1e-9));
      expect(s(120.0), closeTo(30.0, 1e-9));
      expect(s(151.0), closeTo(2.0, 1e-9));
      expect(s(180.0), closeTo(60.0, 1e-9));
      expect(s(181.0), closeTo(59.5, 1e-9));
    });
    test('same-sign returns 0 (conjunction handled separately)', () {
      expect(Aspect.strength(Body.sun, 0.0, 15.0), 0.0);
    });
  });

  group('Aspect.strength — Mars override', () {
    double s(double diff) => Aspect.strength(Body.mars, 0.0, diff);
    test('4th/8th special aspects peak at 60', () {
      expect(s(120.0), closeTo(60.0, 1e-9));
      expect(s(240.0), closeTo(30.0, 1e-9)); // 60 - (240-210) = 30
      expect(s(190.0), closeTo(60.0, 1e-9)); // 180<diff<210
      expect(s(180.0), closeTo(60.0, 1e-9)); // 150<diff<=180
    });
  });

  group('Aspect.strength — Jupiter override', () {
    double s(double diff) => Aspect.strength(Body.jupiter, 0.0, diff);
    test('5th/9th (120°/240°) full aspects', () {
      expect(s(120.0), closeTo(45.0, 1e-9)); // boundary hits (120-90]→lower branch
      expect(s(121.0), closeTo(58.0, 1e-9)); // 60-((121-120)*2)
      expect(s(180.0), closeTo(60.0, 1e-9));
      expect(s(240.0), closeTo(60.0, 1e-9)); // ((240-210)/2)+45
    });
  });

  group('Aspect.strength — Saturn override', () {
    double s(double diff) => Aspect.strength(Body.saturn, 0.0, diff);
    test('3rd/10th (60°/270°) special aspects', () {
      expect(s(61.0), closeTo(59.5, 1e-9)); // 60 - ((61-60)/2)
      expect(s(90.0), closeTo(45.0, 1e-9));
      expect(s(180.0), closeTo(60.0, 1e-9));
      expect(s(270.0), closeTo(60.0, 1e-9)); // (270-240)+30
    });
  });

  group('Aspect.doesAspect', () {
    test('conjunction counts as aspect', () {
      expect(Aspect.doesAspect(Body.sun, 5.0, 25.0), isTrue);
    });
    test('non-aspecting orb returns false', () {
      expect(Aspect.doesAspect(Body.sun, 0.0, 30.0), isFalse);
      expect(Aspect.doesAspect(Body.sun, 0.0, 300.0), isFalse);
    });
    test('7th-house aspect is true', () {
      expect(Aspect.doesAspect(Body.sun, 0.0, 180.0), isTrue);
    });
  });

  test('identity: body to its own longitude → 0 strength', () {
    expect(Aspect.strength(Body.sun, 100.0, 100.0), 0.0);
  });

  test('handles wrap-around longitudes', () {
    // from=350, to=20 → diff=30 → 0 (boundary)
    expect(Aspect.strength(Body.sun, 350.0, 20.0), 0.0);
    // from=350, to=170 → diff=180 → 60
    expect(Aspect.strength(Body.sun, 350.0, 170.0), closeTo(60.0, 1e-9));
  });
}
