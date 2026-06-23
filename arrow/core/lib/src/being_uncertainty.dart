import 'package:arrow_options/arrow_options.dart';

class BeingUncertainty {
  final Map<Body, List<Being>> trimsamsaOptions;
  final Map<Body, List<Being>> horaOptions;

  const BeingUncertainty({
    this.trimsamsaOptions = const {},
    this.horaOptions = const {},
  });

  bool isTrimsamsaUncertain(Body body) =>
      (trimsamsaOptions[body]?.length ?? 0) > 1;

  bool isHoraUncertain(Body body) => (horaOptions[body]?.length ?? 0) > 1;

  bool isUncertain(Body body) =>
      isTrimsamsaUncertain(body) || isHoraUncertain(body);

  static const none = BeingUncertainty();
}
