/// Year-length options for dasha calculations.
///
/// Source: `libaditya/constants.py:dasha_years`.
enum DashaYearLength {
  saura(365.2422),
  nakshatra(359.0167),
  savana(360.0),
  sidereal(365.2564),
  chandra(364.2888),
  lunar(354.36708);

  const DashaYearLength(this.days);
  final double days;
}
