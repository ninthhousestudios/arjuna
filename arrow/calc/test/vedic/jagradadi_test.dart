// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_calc/arrow_calc.dart';
import 'package:arrow_options/arrow_options.dart';
import 'package:test/test.dart';

void main() {
  group('Jagradadi.of', () {
    test('jagrat — exalted / ownSign / moolatrikona', () {
      expect(Jagradadi.of(DignityType.exalted), JagradadiState.jagrat);
      expect(Jagradadi.of(DignityType.ownSign), JagradadiState.jagrat);
      expect(Jagradadi.of(DignityType.moolatrikona), JagradadiState.jagrat);
    });

    test('swapna — friend / greatFriend', () {
      expect(Jagradadi.of(DignityType.friend), JagradadiState.swapna);
      expect(Jagradadi.of(DignityType.greatFriend), JagradadiState.swapna);
    });

    test('sushupti — neutral, enemy, greatEnemy, debilitated', () {
      expect(Jagradadi.of(DignityType.neutral), JagradadiState.sushupti);
      expect(Jagradadi.of(DignityType.enemy), JagradadiState.sushupti);
      expect(Jagradadi.of(DignityType.greatEnemy), JagradadiState.sushupti);
      expect(Jagradadi.of(DignityType.debilitated), JagradadiState.sushupti);
    });

    test('libaditya name', () {
      expect(JagradadiState.jagrat.libadityaName, 'Jagrat');
      expect(JagradadiState.swapna.libadityaName, 'Swapna');
      expect(JagradadiState.sushupti.libadityaName, 'Sushupti');
    });
  });
}
