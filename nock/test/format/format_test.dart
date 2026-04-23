import 'package:arrow_core/arrow_core.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:nock/src/format/format.dart';
import 'package:test/test.dart';

void main() {
  group('table helpers', () {
    test('topBorder', () {
      expect(topBorder(10), '┌────────┐');
    });

    test('bottomBorder', () {
      expect(bottomBorder(10), '└────────┘');
    });

    test('midBorder', () {
      expect(midBorder(10), '├────────┤');
    });

    test('row pads content', () {
      final r = row('hi', 10);
      expect(r, '│ hi     │');
    });

    test('row truncates long content', () {
      final r = row('abcdefghij', 10);
      expect(r, '│ abcdef │');
    });
  });

  group('formatLongitude', () {
    final config = CalcConfig();

    test('formats degrees and arcminutes with sign glyph', () {
      // 84.2 ecliptic -> Longitude computes sign and inSignLongitude
      final lon = Longitude(84.2, 84.2, VargaType.rashi, config);
      final result = formatLongitude(lon);

      // Verify format pattern: DD°MM' <glyph>
      expect(result, matches(RegExp(r"^\s*\d+°\d{2}' .$")));

      // Verify it uses the longitude's own sign
      final glyph = signGlyphs[lon.sign - 1];
      expect(result, contains(glyph));

      // Verify degrees match inSignLongitude
      final d = lon.inSignLongitude.truncate();
      final m = ((lon.inSignLongitude - d) * 60).truncate();
      expect(result, contains('$d°${m.toString().padLeft(2, '0')}'));
    });

    test('zero longitude', () {
      final lon = Longitude(0.0, 0.0, VargaType.rashi, config);
      final result = formatLongitude(lon);
      expect(result, contains("0°00'"));
    });

    test('end of sign', () {
      // 29.99 degrees into a sign
      final lon = Longitude(29.99, 29.99, VargaType.rashi, config);
      final result = formatLongitude(lon);
      final d = lon.inSignLongitude.truncate();
      expect(result, contains('$d°'));
    });

    test('sign abbreviation lookup', () {
      expect(signAbbr(1), 'Ari');
      expect(signAbbr(6), 'Vir');
      expect(signAbbr(12), 'Pis');
    });

    test('sign glyph lookup', () {
      expect(signGlyph(1), '♈');
      expect(signGlyph(3), '♊');
      expect(signGlyph(12), '♓');
    });

    test('sign name delegates to SignData', () {
      expect(signName(1), 'Aries');
      expect(signName(7), 'Libra');
    });
  });

  group('formatCusp', () {
    final config = CalcConfig();

    test('formats house number and longitude', () {
      final cusp = Cusp(1, 122.5, config);
      final result = formatCusp(cusp);

      expect(result, startsWith('House  1:'));
      expect(result, contains("'"));

      final glyph = signGlyphs[cusp.sign - 1];
      expect(result, contains(glyph));
    });

    test('two-digit house number', () {
      final cusp = Cusp(12, 350.0, config);
      final result = formatCusp(cusp);
      expect(result, startsWith('House 12:'));
    });
  });
}
