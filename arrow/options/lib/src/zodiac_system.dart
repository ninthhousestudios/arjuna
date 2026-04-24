/// Which zodiac framework to use for sign assignment.
enum ZodiacSystem {
  /// Standard 12-sign tropical zodiac (equinox-anchored).
  tropical12,

  /// Standard 12-sign sidereal zodiac (ayanamsa-shifted).
  sidereal12,

  /// 13-constellation true-sidereal zodiac using actual boundary stars.
  trueSidereal13,
}
