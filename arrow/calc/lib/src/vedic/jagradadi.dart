import 'package:arrow_options/arrow_options.dart';

/// Jagradadi Avastha — alertness state of a planet based on dignity.
/// Ported from `libaditya/calc/avasthas.py:234-249`.
///
/// - Jagrat (awake): exalted, own sign, or moolatrikona
/// - Swapna (dreaming): friend or great friend
/// - Sushupti (sleeping): everything else (neutral, enemy, great enemy,
///   debilitated)
enum JagradadiState {
  jagrat,
  swapna,
  sushupti;

  static const _names = ['Jagrat', 'Swapna', 'Sushupti'];

  String get libadityaName => _names[index];
}

class Jagradadi {
  const Jagradadi._();

  static JagradadiState of(DignityType dignity) {
    switch (dignity) {
      case DignityType.exalted:
      case DignityType.ownSign:
      case DignityType.moolatrikona:
        return JagradadiState.jagrat;
      case DignityType.friend:
      case DignityType.greatFriend:
        return JagradadiState.swapna;
      case DignityType.neutral:
      case DignityType.enemy:
      case DignityType.greatEnemy:
      case DignityType.debilitated:
        return JagradadiState.sushupti;
    }
  }
}
