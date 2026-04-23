import 'package:arrow_core/arrow_core.dart';

import 'longitude.dart';

/// Format a cusp as "House  1:  2°15' ♍"
String formatCusp(Cusp cusp) {
  final house = cusp.house.toString().padLeft(2);
  final lon = formatLongitude(cusp.longitude);
  return 'House $house: $lon';
}
