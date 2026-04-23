import 'package:arrow_options/arrow_options.dart';

/// Constants for Shadbala calculations. All values ported from libaditya.
class ShadbalaCon {
  const ShadbalaCon._();

  // ---------------------------------------------------------------------------
  // Ucchabala — exaltation points (ecliptic degrees, 0–360)
  // ---------------------------------------------------------------------------

  /// Exact exaltation degree on the ecliptic for each karaka.
  static const exaltationPoint = <Body, double>{
    Body.sun: 10.0,
    Body.moon: 33.0,
    Body.mars: 298.0,
    Body.mercury: 165.0,
    Body.jupiter: 95.0,
    Body.venus: 357.0,
    Body.saturn: 200.0,
  };

  // Moon range-based exaltation: 30–33° = peak (60), 210–213° = debilitation (0).
  static const double moonExaltStart = 30.0;
  static const double moonExaltEnd = 33.0;
  static const double moonDebilStart = 210.0;
  static const double moonDebilEnd = 213.0;

  // Mercury range-based exaltation: 150–165° = peak (60), 330–345° = debilitation (0).
  static const double mercuryExaltStart = 150.0;
  static const double mercuryExaltEnd = 165.0;
  static const double mercuryDebilStart = 330.0;
  static const double mercuryDebilEnd = 345.0;

  // ---------------------------------------------------------------------------
  // Digbala — strongest house for each body
  // ---------------------------------------------------------------------------

  /// House number (1–12) where each body has maximum dig strength.
  /// Sun/Mars = 10 (MC), Moon/Venus = 4 (IC), Mercury/Jupiter = 1 (Asc),
  /// Saturn = 7 (Desc).
  static const digbalaHouse = <Body, int>{
    Body.sun: 10,
    Body.moon: 4,
    Body.mars: 10,
    Body.mercury: 1,
    Body.jupiter: 1,
    Body.venus: 4,
    Body.saturn: 7,
  };

  // ---------------------------------------------------------------------------
  // Cheshta bala — mean longitude polynomials (degrees, T = Julian centuries
  // from J2000 = JD 2451545.0). Coefficients: [a0, a1, a2, a3].
  // ---------------------------------------------------------------------------

  static const _sunCoeffs = [280.466449, 36000.7698231, 0.00030368, 0.000000021];
  static const _marsCoeffs = [355.433275, 19141.6964746, 0.00031097, 0.000000015];
  static const _mercuryCoeffs = [252.250906, 149474.0722491, 0.00030397, -0.000000018];
  static const _jupiterCoeffs = [34.351484, 3036.3027889, 0.00022374, 0.000000025];
  static const _venusCoeffs = [181.979801, 58519.2130302, 0.00031060, 0.000000015];
  static const _saturnCoeffs = [50.07741, 1223.5110141, 0.00051952, -0.000000003];

  static const meanLonCoeffs = <Body, List<double>>{
    Body.sun: _sunCoeffs,
    Body.mars: _marsCoeffs,
    Body.mercury: _mercuryCoeffs,
    Body.jupiter: _jupiterCoeffs,
    Body.venus: _venusCoeffs,
    Body.saturn: _saturnCoeffs,
  };

  // ---------------------------------------------------------------------------
  // Saptavargaja bala — dignity point values
  // ---------------------------------------------------------------------------

  /// Points per dignity for one varga in the saptavargaja sum.
  /// Exalted and debilitated use compound friendship — not in this table.
  static const saptavargajaPoints = <DignityType, double>{
    DignityType.moolatrikona: 45.0,
    DignityType.ownSign: 30.0,
    DignityType.greatFriend: 20.0,
    DignityType.friend: 15.0,
    DignityType.neutral: 10.0,
    DignityType.enemy: 4.0,
    DignityType.greatEnemy: 2.0,
  };

  /// Points for compound friendship levels (used when dignity is exalted or
  /// debilitated — substitute the friendship level for that placement).
  static const compoundFriendshipPoints = <FriendshipLevel, double>{
    FriendshipLevel.greatFriend: 20.0,
    FriendshipLevel.friend: 15.0,
    FriendshipLevel.neutral: 10.0,
    FriendshipLevel.enemy: 4.0,
    FriendshipLevel.greatEnemy: 2.0,
  };
}

