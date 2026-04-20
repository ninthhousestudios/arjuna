import 'package:arrow_options/arrow_options.dart';

class NakshatraData {
  NakshatraData._();

  /// Vimshottari dasha lords (1-27 → Body)
  /// Cycle: Ketu, Venus, Sun, Moon, Mars, Rahu, Jupiter, Saturn, Mercury (repeats 3×)
  static const lords = <int, Body>{
    1: Body.ketu,     // Ashwini
    2: Body.venus,    // Bharani
    3: Body.sun,      // Krittika
    4: Body.moon,     // Rohini
    5: Body.mars,     // Mrigashira
    6: Body.rahu,     // Ardra
    7: Body.jupiter,  // Punarvasu
    8: Body.saturn,   // Pushya
    9: Body.mercury,  // Ashlesha
    10: Body.ketu,    // Magha
    11: Body.venus,   // Purva Phalguni
    12: Body.sun,     // Uttara Phalguni
    13: Body.moon,    // Hasta
    14: Body.mars,    // Chitra
    15: Body.rahu,    // Swati
    16: Body.jupiter, // Vishakha
    17: Body.saturn,  // Anuradha
    18: Body.mercury, // Jyeshtha
    19: Body.ketu,    // Mula
    20: Body.venus,   // Purva Ashadha
    21: Body.sun,     // Uttara Ashadha
    22: Body.moon,    // Shravana
    23: Body.mars,    // Dhanishtha
    24: Body.rahu,    // Shatabhisha
    25: Body.jupiter, // Purva Bhadrapada
    26: Body.saturn,  // Uttara Bhadrapada
    27: Body.mercury, // Revati
  };

  /// Presiding deities
  static const deities = <int, String>{
    1: 'Ashvini Kumaras',
    2: 'Yama',
    3: 'Agni',
    4: 'Brahma',
    5: 'Soma',
    6: 'Rudra',
    7: 'Aditi',
    8: 'Brihaspati',
    9: 'Sarpa',
    10: 'Pitris',
    11: 'Bhaga',
    12: 'Aryaman',
    13: 'Savitar',
    14: 'Tvashtar',
    15: 'Vayu',
    16: 'Indragni',
    17: 'Mitra',
    18: 'Indra',
    19: 'Nirriti',
    20: 'Apas',
    21: 'Vishvadevas',
    22: 'Vishnu',
    23: 'Vasu',
    24: 'Varuna',
    25: 'Ajaikapad',
    26: 'Ahirbudhnya',
    27: 'Pushan',
  };

  /// Nakshatra names
  static const names = <int, String>{
    1: 'Ashwini',          2: 'Bharani',           3: 'Krittika',
    4: 'Rohini',           5: 'Mrigashira',         6: 'Ardra',
    7: 'Punarvasu',        8: 'Pushya',             9: 'Ashlesha',
    10: 'Magha',          11: 'Purva Phalguni',    12: 'Uttara Phalguni',
    13: 'Hasta',          14: 'Chitra',            15: 'Swati',
    16: 'Vishakha',       17: 'Anuradha',          18: 'Jyeshtha',
    19: 'Mula',           20: 'Purva Ashadha',     21: 'Uttara Ashadha',
    22: 'Shravana',       23: 'Dhanishtha',        24: 'Shatabhisha',
    25: 'Purva Bhadrapada', 26: 'Uttara Bhadrapada', 27: 'Revati',
  };

  static Body lord(int nak) => lords[nak]!;
  static String deity(int nak) => deities[nak]!;
  static String name(int nak) => names[nak]!;
}
