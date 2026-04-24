/// The 13 astronomical constellations of the ecliptic.
///
/// Ordered by ecliptic longitude of the first boundary star. Includes
/// Ophiuchus between Scorpio and Sagittarius. The built-in [index]
/// property (0-12) matches the ecliptic order.
enum ConstellationId {
  aries('Aries'),
  taurus('Taurus'),
  gemini('Gemini'),
  cancer('Cancer'),
  leo('Leo'),
  virgo('Virgo'),
  libra('Libra'),
  scorpio('Scorpio'),
  ophiuchus('Ophiuchus'),
  sagittarius('Sagittarius'),
  capricorn('Capricorn'),
  aquarius('Aquarius'),
  pisces('Pisces'),
  ;

  final String label;

  const ConstellationId(this.label);
}
