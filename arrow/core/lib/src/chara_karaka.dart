import 'karaka.dart';

/// Jaimini chara karaka role names (descending in-sign longitude order).
enum CharaKarakaRole {
  atmakaraka,
  amatyakaraka,
  bhratrikaraka,
  matrikaraka,
  putrakaraka,
  gnatikaraka,
  darakaraka,
  striDarakaraka, // 8th, optional (when count = 8)
}

/// Assigns Jaimini chara karaka roles by sorting karakas by in-sign longitude.
///
/// The planet with the highest in-sign longitude becomes Atmakaraka, the
/// next becomes Amatyakaraka, and so on.
class CharaKaraka {
  CharaKaraka._();

  /// Assign chara karaka roles to the given karakas.
  ///
  /// [count] is 7 (default) or 8 (includes Rahu as potential 8th karaka).
  /// Returns a map from role to the karaka assigned that role.
  static Map<CharaKarakaRole, Karaka> assign(List<Karaka> karakas,
      {int count = 7}) {
    final sorted = [...karakas]
      ..sort(
          (a, b) => b.inSignLongitude.compareTo(a.inSignLongitude));

    final roles = CharaKarakaRole.values;
    return {
      for (var i = 0; i < count && i < sorted.length && i < roles.length; i++)
        roles[i]: sorted[i],
    };
  }
}
