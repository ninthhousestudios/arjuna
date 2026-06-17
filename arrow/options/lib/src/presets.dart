import 'arrow_options_data.dart';
import 'ayanamsa.dart';
import 'body.dart';
import 'calc_config.dart';
import 'circle.dart';
import 'house_system.dart';
import 'swe_config.dart';
import 'tradition.dart';
import 'vedic_config.dart';

/// Pre-built ArrowOptions for common use cases.
abstract final class ArrowPresets {
  /// Aditya system: tropical signs, Aditya circle, dhruva equatorial nakshatras.
  static const aditya = ArrowOptions(
    sweConfig: SweConfig(
      signAyanamsa: Ayanamsa.tropical,
      nakAyanamsa: Ayanamsa.dhruva,
      houseSystem: HouseSystem.campanus,
    ),
    calcConfig: CalcConfig(
      circle: Circle.aditya,
      nakEquatorial: true,
      traditions: {Tradition.vedic},
      vedic: VedicConfig(),
    ),
  );

  /// Lahiri Vedic: Lahiri sidereal, zodiac circle, Lahiri nakshatras.
  static const lahiriVedic = ArrowOptions(
    sweConfig: SweConfig(
      signAyanamsa: Ayanamsa.lahiri,
      nakAyanamsa: Ayanamsa.lahiri,
      houseSystem: HouseSystem.wholeSigns,
    ),
    calcConfig: CalcConfig(
      circle: Circle.zodiac,
      nakEquatorial: false,
      traditions: {Tradition.vedic},
      vedic: VedicConfig(),
    ),
  );

  /// Western tropical: tropical signs, zodiac circle, no Vedic config.
  static const westernTropical = ArrowOptions(
    sweConfig: SweConfig(
      signAyanamsa: Ayanamsa.tropical,
      houseSystem: HouseSystem.placidus,
      bodies: {
        Body.sun,
        Body.moon,
        Body.mercury,
        Body.venus,
        Body.mars,
        Body.jupiter,
        Body.saturn,
        Body.uranus,
        Body.neptune,
        Body.pluto,
      },
    ),
    calcConfig: CalcConfig(circle: Circle.zodiac, traditions: {}),
  );
}
