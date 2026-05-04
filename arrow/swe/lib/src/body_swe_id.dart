import 'package:arrow_options/arrow_options.dart';

const _bodySweIds = <Body, int>{
  Body.sun: 0,
  Body.moon: 1,
  Body.mercury: 2,
  Body.venus: 3,
  Body.mars: 4,
  Body.jupiter: 5,
  Body.saturn: 6,
  Body.uranus: 7,
  Body.neptune: 8,
  Body.pluto: 9,
  Body.chiron: 15,
  Body.rahu: 11,
  Body.ketu: -1,
};

int sweIdFor(Body body) => _bodySweIds[body]!;
