@Tags(['integration'])
library;

import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_swe/arrow_swe.dart';
import 'package:swisseph/swisseph.dart';
import 'package:test/test.dart';

import 'helpers/find_ephe_path.dart';

void main() {
  final ephePath = findEphePath();
  final skipReason =
      ephePath == null ? 'no ephe path found; set ARROW_EPHE_PATH' : null;

  group('FixedStar', skip: skipReason, () {
    const jdUt = 2451545.0; // J2000

    late SwissEph swe;
    late SweFacade facade;

    setUp(() {
      swe = SwissEph.find();
      facade = SweFacade(swe, ephePath: ephePath);
    });

    tearDown(() {
      swe.close();
    });

    test('extends SkyObject', () {
      final options = ArrowOptions(
        sweConfig: SweConfig(stars: {Star.aldebaran}),
      );
      final snap = facade.calcAll(jdUt, _testLocation, options);
      final fs = FixedStar.fromEnum(Star.aldebaran, snap, CalcConfig());
      expect(fs, isA<SkyObject>());
    });

    test('fromEnum resolves sign and nakshatra', () {
      final options = ArrowOptions(
        sweConfig: SweConfig(stars: {Star.aldebaran}),
      );
      final snap = facade.calcAll(jdUt, _testLocation, options);
      final fs = FixedStar.fromEnum(Star.aldebaran, snap, CalcConfig());

      expect(fs.star, Star.aldebaran);
      expect(fs.name, 'Aldebaran');
      expect(fs.junctionOf, 4);
      // Aldebaran tropical ~69.8° → sign depends on Circle config
      expect(fs.sign, inInclusiveRange(1, 12));
      expect(fs.nakshatra, inInclusiveRange(1, 27));
      expect(fs.pada, inInclusiveRange(1, 4));
    });

    test('custom star resolves', () {
      final options = ArrowOptions(
        sweConfig: SweConfig(
          bodies: {},
          customStarNames: {'Sirius'},
        ),
      );
      final snap = facade.calcAll(jdUt, _testLocation, options);
      final fs = FixedStar.custom('Sirius', snap, CalcConfig());

      expect(fs.star, isNull);
      expect(fs.name, 'Sirius');
      expect(fs.junctionOf, isNull);
      // Sirius tropical ~104° → sign depends on Circle config
      expect(fs.sign, inInclusiveRange(1, 12));
    });

    test('Chart.fixedStars populated from snapshot', () {
      final options = ArrowOptions(
        sweConfig: SweConfig(stars: {Star.spica, Star.regulus}),
      );
      final snap = facade.calcAll(jdUt, _testLocation, options);
      final chart = Chart(snap, CalcConfig());

      expect(chart.fixedStars, hasLength(2));
      expect(chart.fixedStars.keys, containsAll([Star.spica, Star.regulus]));
      expect(chart.fixedStars[Star.spica], isA<FixedStar>());
    });

    test('Chart with no stars has empty fixedStars', () {
      final options = ArrowOptions();
      final snap = facade.calcAll(jdUt, _testLocation, options);
      final chart = Chart(snap, CalcConfig());

      expect(chart.fixedStars, isEmpty);
      expect(chart.customFixedStars, isEmpty);
    });

    test('varga always returns rashi for FixedStar', () {
      final options = ArrowOptions(
        sweConfig: SweConfig(stars: {Star.aldebaran}),
      );
      final snap = facade.calcAll(jdUt, _testLocation, options);
      final fs = FixedStar.fromEnum(Star.aldebaran, snap, CalcConfig());

      expect(fs.vargaType, VargaType.rashi);
    });
  });
}

const _testLocation = Location(
  latitude: 28.6139,
  longitude: 77.2090,
  altitude: 0.0,
);
