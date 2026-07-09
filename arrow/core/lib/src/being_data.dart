// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

class BeingData {
  BeingData._();

  static Being forSign(int sign, BeingType type) {
    final being = _beings[(sign, type)];
    if (being == null) {
      throw ArgumentError('No being for sign $sign, type $type');
    }
    return being;
  }

  static const _beings = <(int, BeingType), Being>{
    // 1
    (1, BeingType.gandharva): Being(
      name: 'Tumburu',
      type: BeingType.gandharva,
      signNumber: 1,
    ),
    (1, BeingType.rakshasa): Being(
      name: 'Heti',
      type: BeingType.rakshasa,
      signNumber: 1,
    ),
    (1, BeingType.rishi): Being(
      name: 'Pulastya',
      type: BeingType.rishi,
      signNumber: 1,
    ),
    (1, BeingType.yaksha): Being(
      name: 'Rathakrit',
      type: BeingType.yaksha,
      signNumber: 1,
    ),
    (1, BeingType.apsara): Being(
      name: 'Kritasthali',
      type: BeingType.apsara,
      signNumber: 1,
    ),

    // 2
    (2, BeingType.gandharva): Being(
      name: 'Narada',
      type: BeingType.gandharva,
      signNumber: 2,
    ),
    (2, BeingType.rakshasa): Being(
      name: 'Praheti',
      type: BeingType.rakshasa,
      signNumber: 2,
    ),
    (2, BeingType.rishi): Being(
      name: 'Pulaha',
      type: BeingType.rishi,
      signNumber: 2,
    ),
    (2, BeingType.yaksha): Being(
      name: 'Rathauja',
      type: BeingType.yaksha,
      signNumber: 2,
    ),
    (2, BeingType.apsara): Being(
      name: 'Punjikasthali',
      type: BeingType.apsara,
      signNumber: 2,
    ),

    // 3
    (3, BeingType.gandharva): Being(
      name: 'Haha',
      type: BeingType.gandharva,
      signNumber: 3,
    ),
    (3, BeingType.rakshasa): Being(
      name: 'Paurusheya',
      type: BeingType.rakshasa,
      signNumber: 3,
    ),
    (3, BeingType.rishi): Being(
      name: 'Atri',
      type: BeingType.rishi,
      signNumber: 3,
    ),
    (3, BeingType.yaksha): Being(
      name: 'Rathasvana',
      type: BeingType.yaksha,
      signNumber: 3,
    ),
    (3, BeingType.apsara): Being(
      name: 'Menaka',
      type: BeingType.apsara,
      signNumber: 3,
    ),

    // 4
    (4, BeingType.gandharva): Being(
      name: 'Huhu',
      type: BeingType.gandharva,
      signNumber: 4,
    ),
    (4, BeingType.rakshasa): Being(
      name: 'Chitrasvana',
      type: BeingType.rakshasa,
      signNumber: 4,
    ),
    (4, BeingType.rishi): Being(
      name: 'Vasishtha',
      type: BeingType.rishi,
      signNumber: 4,
    ),
    (4, BeingType.yaksha): Being(
      name: 'Rathacitra',
      type: BeingType.yaksha,
      signNumber: 4,
    ),
    (4, BeingType.apsara): Being(
      name: 'Sahajanya',
      type: BeingType.apsara,
      signNumber: 4,
    ),

    // 5
    (5, BeingType.gandharva): Being(
      name: 'Vishvavasu',
      type: BeingType.gandharva,
      signNumber: 5,
    ),
    (5, BeingType.rakshasa): Being(
      name: 'Varya',
      type: BeingType.rakshasa,
      signNumber: 5,
    ),
    (5, BeingType.rishi): Being(
      name: 'Angiras',
      type: BeingType.rishi,
      signNumber: 5,
    ),
    (5, BeingType.yaksha): Being(
      name: 'Shrota',
      type: BeingType.yaksha,
      signNumber: 5,
    ),
    (5, BeingType.apsara): Being(
      name: 'Pramlocha',
      type: BeingType.apsara,
      signNumber: 5,
    ),

    // 6
    (6, BeingType.gandharva): Being(
      name: 'Ugrasena',
      type: BeingType.gandharva,
      signNumber: 6,
    ),
    (6, BeingType.rakshasa): Being(
      name: 'Vyaghra',
      type: BeingType.rakshasa,
      signNumber: 6,
    ),
    (6, BeingType.rishi): Being(
      name: 'Bhrigu',
      type: BeingType.rishi,
      signNumber: 6,
    ),
    (6, BeingType.yaksha): Being(
      name: 'Asarana',
      type: BeingType.yaksha,
      signNumber: 6,
    ),
    (6, BeingType.apsara): Being(
      name: 'Anumlocha',
      type: BeingType.apsara,
      signNumber: 6,
    ),

    // 7
    (7, BeingType.gandharva): Being(
      name: 'Dhritarashtra',
      type: BeingType.gandharva,
      signNumber: 7,
    ),
    (7, BeingType.rakshasa): Being(
      name: 'Brahmapeta',
      type: BeingType.rakshasa,
      signNumber: 7,
    ),
    (7, BeingType.rishi): Being(
      name: 'Jamadagni',
      type: BeingType.rishi,
      signNumber: 7,
    ),
    (7, BeingType.yaksha): Being(
      name: 'Shatajit',
      type: BeingType.yaksha,
      signNumber: 7,
    ),
    (7, BeingType.apsara): Being(
      name: 'Tilottama',
      type: BeingType.apsara,
      signNumber: 7,
    ),

    // 8
    (8, BeingType.gandharva): Being(
      name: 'Suryavarcas',
      type: BeingType.gandharva,
      signNumber: 8,
    ),
    (8, BeingType.rakshasa): Being(
      name: 'Makhapeta',
      type: BeingType.rakshasa,
      signNumber: 8,
    ),
    (8, BeingType.rishi): Being(
      name: 'Vishvamitra',
      type: BeingType.rishi,
      signNumber: 8,
    ),
    (8, BeingType.yaksha): Being(
      name: 'Satyajit',
      type: BeingType.yaksha,
      signNumber: 8,
    ),
    (8, BeingType.apsara): Being(
      name: 'Rambha',
      type: BeingType.apsara,
      signNumber: 8,
    ),

    // 9
    (9, BeingType.gandharva): Being(
      name: 'Ritasena',
      type: BeingType.gandharva,
      signNumber: 9,
    ),
    (9, BeingType.rakshasa): Being(
      name: 'Vidyucchatru',
      type: BeingType.rakshasa,
      signNumber: 9,
    ),
    (9, BeingType.rishi): Being(
      name: 'Kashyapa',
      type: BeingType.rishi,
      signNumber: 9,
    ),
    (9, BeingType.yaksha): Being(
      name: 'Tarkshya',
      type: BeingType.yaksha,
      signNumber: 9,
    ),
    (9, BeingType.apsara): Being(
      name: 'Urvashi',
      type: BeingType.apsara,
      signNumber: 9,
    ),

    // 10
    (10, BeingType.gandharva): Being(
      name: 'Urna',
      type: BeingType.gandharva,
      signNumber: 10,
    ),
    (10, BeingType.rakshasa): Being(
      name: 'Sphurja',
      type: BeingType.rakshasa,
      signNumber: 10,
    ),
    (10, BeingType.rishi): Being(
      name: 'Ayu',
      type: BeingType.rishi,
      signNumber: 10,
    ),
    (10, BeingType.yaksha): Being(
      name: 'Arishtanemi',
      type: BeingType.yaksha,
      signNumber: 10,
    ),
    (10, BeingType.apsara): Being(
      name: 'Purvacitti',
      type: BeingType.apsara,
      signNumber: 10,
    ),

    // 11
    (11, BeingType.gandharva): Being(
      name: 'Suruci',
      type: BeingType.gandharva,
      signNumber: 11,
    ),
    (11, BeingType.rakshasa): Being(
      name: 'Vata',
      type: BeingType.rakshasa,
      signNumber: 11,
    ),
    (11, BeingType.rishi): Being(
      name: 'Gautama',
      type: BeingType.rishi,
      signNumber: 11,
    ),
    (11, BeingType.yaksha): Being(
      name: 'Sushena',
      type: BeingType.yaksha,
      signNumber: 11,
    ),
    (11, BeingType.apsara): Being(
      name: 'Ghritachi',
      type: BeingType.apsara,
      signNumber: 11,
    ),

    // 12
    (12, BeingType.gandharva): Being(
      name: 'Vishvavasu',
      type: BeingType.gandharva,
      signNumber: 12,
    ),
    (12, BeingType.rakshasa): Being(
      name: 'Varca',
      type: BeingType.rakshasa,
      signNumber: 12,
    ),
    (12, BeingType.rishi): Being(
      name: 'Bharadvaja',
      type: BeingType.rishi,
      signNumber: 12,
    ),
    (12, BeingType.yaksha): Being(
      name: 'Senajit',
      type: BeingType.yaksha,
      signNumber: 12,
    ),
    (12, BeingType.apsara): Being(
      name: 'Vishvaci',
      type: BeingType.apsara,
      signNumber: 12,
    ),

    // Adityas (hora = sun)
    (1, BeingType.aditya): Being(
      name: 'Dhata',
      type: BeingType.aditya,
      signNumber: 1,
    ),
    (2, BeingType.aditya): Being(
      name: 'Aryama',
      type: BeingType.aditya,
      signNumber: 2,
    ),
    (3, BeingType.aditya): Being(
      name: 'Mitra',
      type: BeingType.aditya,
      signNumber: 3,
    ),
    (4, BeingType.aditya): Being(
      name: 'Varuna',
      type: BeingType.aditya,
      signNumber: 4,
    ),
    (5, BeingType.aditya): Being(
      name: 'Indra',
      type: BeingType.aditya,
      signNumber: 5,
    ),
    (6, BeingType.aditya): Being(
      name: 'Vivasvan',
      type: BeingType.aditya,
      signNumber: 6,
    ),
    (7, BeingType.aditya): Being(
      name: 'Tvashta',
      type: BeingType.aditya,
      signNumber: 7,
    ),
    (8, BeingType.aditya): Being(
      name: 'Vishnu',
      type: BeingType.aditya,
      signNumber: 8,
    ),
    (9, BeingType.aditya): Being(
      name: 'Amshu',
      type: BeingType.aditya,
      signNumber: 9,
    ),
    (10, BeingType.aditya): Being(
      name: 'Bhaga',
      type: BeingType.aditya,
      signNumber: 10,
    ),
    (11, BeingType.aditya): Being(
      name: 'Pusha',
      type: BeingType.aditya,
      signNumber: 11,
    ),
    (12, BeingType.aditya): Being(
      name: 'Parjanya',
      type: BeingType.aditya,
      signNumber: 12,
    ),

    // Nagas (hora = moon)
    (1, BeingType.naga): Being(
      name: 'Vasuki',
      type: BeingType.naga,
      signNumber: 1,
    ),
    (2, BeingType.naga): Being(
      name: 'Kacchanira',
      type: BeingType.naga,
      signNumber: 2,
    ),
    (3, BeingType.naga): Being(
      name: 'Takshaka',
      type: BeingType.naga,
      signNumber: 3,
    ),
    (4, BeingType.naga): Being(
      name: 'Shukra',
      type: BeingType.naga,
      signNumber: 4,
    ),
    (5, BeingType.naga): Being(
      name: 'Elapatra',
      type: BeingType.naga,
      signNumber: 5,
    ),
    (6, BeingType.naga): Being(
      name: 'Shankhapala',
      type: BeingType.naga,
      signNumber: 6,
    ),
    (7, BeingType.naga): Being(
      name: 'Kambala',
      type: BeingType.naga,
      signNumber: 7,
    ),
    (8, BeingType.naga): Being(
      name: 'Ashvatara',
      type: BeingType.naga,
      signNumber: 8,
    ),
    (9, BeingType.naga): Being(
      name: 'Mahashankha',
      type: BeingType.naga,
      signNumber: 9,
    ),
    (10, BeingType.naga): Being(
      name: 'Karkotaka',
      type: BeingType.naga,
      signNumber: 10,
    ),
    (11, BeingType.naga): Being(
      name: 'Dhananjaya',
      type: BeingType.naga,
      signNumber: 11,
    ),
    (12, BeingType.naga): Being(
      name: 'Airavata',
      type: BeingType.naga,
      signNumber: 12,
    ),
  };
}
