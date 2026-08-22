/// Fixed-angle calculation methods used by Islamic timekeeping authorities.
///
/// These are the traditional presets. They are offered for comparison and for callers who
/// must match a specific authority's published timetable; the package's own default is the
/// dynamic method, which adapts the twilight angle to season, latitude, Earth-Sun distance
/// and local atmospheric conditions rather than fixing it.
///
/// A fixed angle is exactly what fails at high latitude: above roughly 48.5 degrees the sun
/// stops reaching 18 degrees below the horizon in summer, so an 18-degree method simply has
/// no answer. [getTimesAll] reports such a method as absent for that date rather than
/// substituting a value, which is the point of the map: it shows you which methods are
/// applicable where.
///
/// Values mirror the JavaScript `pray-calc` package exactly.
library;

/// One fixed-angle (or seasonal) calculation method.
class MethodDefinition {
  /// Short identifier, used as the key in the [PrayerTimesAll.methods] map.
  final String id;

  /// Human-readable name of the issuing authority.
  final String name;

  /// Geographic region of primary use.
  final String region;

  /// Fajr depression angle in degrees, or null when the method uses a seasonal
  /// calculation (MSC) rather than a fixed angle.
  final double? fajrAngle;

  /// Isha depression angle in degrees, or null when the method uses a fixed-minute
  /// offset ([ishaMinutes]) or a seasonal calculation instead.
  final double? ishaAngle;

  /// Fixed minutes after Maghrib for Isha, used by Umm Al-Qura and Qatar.
  final int? ishaMinutes;

  /// True for the Moonsighting Committee Worldwide seasonal model, which derives Fajr and
  /// Isha as minute offsets from sunrise/sunset rather than from a depression angle.
  final bool useMsc;

  const MethodDefinition({
    required this.id,
    required this.name,
    required this.region,
    this.fajrAngle,
    this.ishaAngle,
    this.ishaMinutes,
    this.useMsc = false,
  });

  @override
  String toString() => 'MethodDefinition($id)';
}

/// Every supported fixed-angle and seasonal method.
///
/// Ordered by Fajr angle, with one deliberate exception: Umm Al-Qura (18.5) and Qatar (18)
/// are listed adjacently because they are the two fixed-minute Isha methods and belong
/// together. Order is presentational only — nothing in the calculation depends on it.
///
/// Tehran/Jafari is deliberately absent: it is a Shia method and outside this package's
/// scope.
const List<MethodDefinition> kMethods = [
  MethodDefinition(
    id: 'UOIF',
    name: 'Union des Organisations Islamiques de France',
    region: 'France',
    fajrAngle: 12,
    ishaAngle: 12,
  ),
  MethodDefinition(
    id: 'ISNACA',
    name: 'IQNA / Islamic Council of North America',
    region: 'Canada',
    fajrAngle: 13,
    ishaAngle: 13,
  ),
  MethodDefinition(
    id: 'ISNA',
    name: 'FCNA / Islamic Society of North America',
    region: 'US, UK, AU, NZ',
    fajrAngle: 15,
    ishaAngle: 15,
  ),
  MethodDefinition(
    id: 'SAMR',
    name: 'Spiritual Administration of Muslims of Russia',
    region: 'Russia',
    fajrAngle: 16,
    ishaAngle: 15,
  ),
  MethodDefinition(
    id: 'IGUT',
    name: 'Institute of Geophysics, University of Tehran',
    region: 'Iran',
    fajrAngle: 17.7,
    ishaAngle: 14,
  ),
  MethodDefinition(
    id: 'MWL',
    name: 'Muslim World League',
    region: 'Global',
    fajrAngle: 18,
    ishaAngle: 17,
  ),
  MethodDefinition(
    id: 'DIBT',
    name: 'Diyanet İşleri Başkanlığı, Turkey',
    region: 'Turkey',
    fajrAngle: 18,
    ishaAngle: 17,
  ),
  MethodDefinition(
    id: 'Karachi',
    name: 'University of Islamic Sciences, Karachi',
    region: 'PK, BD, IN, AF',
    fajrAngle: 18,
    ishaAngle: 18,
  ),
  MethodDefinition(
    id: 'Kuwait',
    name: 'Kuwait Ministry of Islamic Affairs',
    region: 'Kuwait',
    fajrAngle: 18,
    ishaAngle: 17.5,
  ),
  MethodDefinition(
    id: 'UAQ',
    name: 'Umm Al-Qura University, Makkah',
    region: 'Saudi Arabia',
    fajrAngle: 18.5,
    ishaMinutes: 90,
  ),
  MethodDefinition(
    id: 'Qatar',
    name: 'Qatar / Gulf Standard',
    region: 'Qatar, Gulf',
    fajrAngle: 18,
    ishaMinutes: 90,
  ),
  MethodDefinition(
    id: 'Egypt',
    name: 'Egyptian General Authority of Survey',
    region: 'EG, SY, IQ, LB',
    fajrAngle: 19.5,
    ishaAngle: 17.5,
  ),
  MethodDefinition(
    id: 'MUIS',
    name: 'Majlis Ugama Islam Singapura',
    region: 'Singapore',
    fajrAngle: 20,
    ishaAngle: 18,
  ),
  MethodDefinition(
    id: 'MSC',
    name: 'Moonsighting Committee Worldwide',
    region: 'Global',
    useMsc: true,
  ),
];
