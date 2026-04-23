import 'package:arrow_core/arrow_core.dart';

import '../../format/cusp.dart';
import '../error.dart';
import 'astro.dart';
import 'value.dart';

class NockCusp extends NockValue {
  final Cusp cusp;

  NockCusp(this.cusp);

  @override
  String display() => formatCusp(cusp);

  @override
  NockValue access(String field) => switch (field) {
        'longitude' => NockNumber(cusp.longitude.eclipticLongitude),
        'sign' => NockSign(cusp.sign, cusp.longitude),
        'nakshatra' => NockNakshatra(cusp.nakshatra, cusp.pada),
        'house' => NockNumber(cusp.house.toDouble()),
        _ => throw NockError('cusp has no property "$field"'),
      };

  @override
  String typeName() => 'cusp';
}
