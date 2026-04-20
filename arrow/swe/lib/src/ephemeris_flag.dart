import 'package:arrow_options/arrow_options.dart';
import 'package:swisseph/swisseph.dart';

/// Map an [EphemerisSource] to its SWE calc flag bit.
///
/// [EphemerisSource.jplEph] additionally requires `jplFile` to have been
/// passed when constructing the [SweFacade]; SWE will otherwise fail at
/// calc time with a file-not-found error.
int ephemerisFlag(EphemerisSource source) {
  switch (source) {
    case EphemerisSource.swissEph:
      return seFlgSwiEph;
    case EphemerisSource.moshier:
      return seFlgMosEph;
    case EphemerisSource.jplEph:
      return seFlgJplEph;
  }
}
