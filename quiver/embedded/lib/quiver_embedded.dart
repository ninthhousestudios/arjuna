/// Vayu — local embedded Quiver for in-process Arrow access.
library;

export 'src/vayu.dart';

// Re-export domain types so consumers need only one import.
export 'package:arrow_core/arrow_core.dart';
export 'package:arrow_options/arrow_options.dart';
export 'package:arrow_swe/arrow_swe.dart';
export 'package:quiver_core/quiver_core.dart'
    show CalculationPreset, RequestMapper;
