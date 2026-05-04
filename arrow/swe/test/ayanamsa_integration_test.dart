@Tags(['integration'])
library;

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:swisseph/swisseph.dart';
import 'package:test/test.dart';

import 'helpers/find_ephe_path.dart';

void main() {
  final ephePath = findEphePath();
  final skipReason = ephePath == null
      ? 'no ephe path found; set ARROW_EPHE_PATH'
      : null;

  group('SweFacade.getAyanamsa', skip: skipReason, () {
    const jdUt = 2451545.0; // J2000
    const jdEt = 2451545.0;

    late SwissEph swe;
    late SweFacade facade;

    setUp(() {
      swe = SwissEph.find();
      facade = SweFacade(swe, ephePath: ephePath);
    });

    tearDown(() {
      swe.close();
    });

    test('tropical returns 0.0', () {
      expect(facade.getAyanamsa(jdEt, Ayanamsa.tropical), equals(0.0));
      expect(facade.getAyanamsaUt(jdUt, Ayanamsa.tropical), equals(0.0));
    });

    test('Lahiri at J2000 matches raw SWE call', () {
      swe.setSidMode(Ayanamsa.lahiri.sweCode);
      final expected = swe.getAyanamsa(jdEt);
      expect(
        facade.getAyanamsa(jdEt, Ayanamsa.lahiri),
        closeTo(expected, 1e-9),
      );
    });

    test('UT and ET variants differ by ~delta-T worth of precession', () {
      final ut = facade.getAyanamsaUt(jdUt, Ayanamsa.lahiri);
      final et = facade.getAyanamsa(jdEt, Ayanamsa.lahiri);
      expect(et, closeTo(ut, 0.001));
    });

    test('switching between ayanamsas is stateless from caller view', () {
      final lahiri = facade.getAyanamsa(jdEt, Ayanamsa.lahiri);
      final fagan = facade.getAyanamsa(jdEt, Ayanamsa.fagan);
      final lahiriAgain = facade.getAyanamsa(jdEt, Ayanamsa.lahiri);
      expect(lahiriAgain, closeTo(lahiri, 1e-9));
      expect(fagan, isNot(closeTo(lahiri, 0.01)));
    });
  });
}
