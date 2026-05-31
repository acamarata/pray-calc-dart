/// Core types for pray_calc_dart.
library;

/// Asr shadow convention: Shafi'i (1x) or Hanafi (2x).
enum AsrConvention { shafii, hanafi }

/// Shafaq variant for MSC Isha model.
enum ShafaqMode { general, ahmer, abyad }

/// Computed twilight depression angles for Fajr and Isha.
class TwilightAngles {
  /// Solar depression angle for Fajr (positive degrees below horizon).
  final double fajrAngle;

  /// Solar depression angle for Isha (positive degrees below horizon).
  final double ishaAngle;

  const TwilightAngles({required this.fajrAngle, required this.ishaAngle});
}

/// Raw prayer times as fractional hours. NaN = unreachable event.
class PrayerTimes {
  /// Start of the last third of the night (Qiyam al-Layl).
  final double qiyam;

  /// True dawn (Subh Sadiq).
  final double fajr;

  /// Astronomical sunrise.
  final double sunrise;

  /// Solar noon (exact geometric transit).
  final double noon;

  /// Dhuhr (2.5 minutes after solar noon).
  final double dhuhr;

  /// Asr (Shafi'i or Hanafi shadow convention).
  final double asr;

  /// Maghrib (sunset).
  final double maghrib;

  /// Isha (nightfall, end of shafaq).
  final double isha;

  /// Dynamic twilight angles used for this calculation.
  final TwilightAngles angles;

  const PrayerTimes({
    required this.qiyam,
    required this.fajr,
    required this.sunrise,
    required this.noon,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.angles,
  });
}

/// Prayer times formatted as HH:MM:SS strings.
class FormattedPrayerTimes {
  /// Start of the last third of the night (Qiyam al-Layl), as HH:MM:SS.
  final String qiyam;

  /// True dawn (Subh Sadiq), as HH:MM:SS.
  final String fajr;

  /// Astronomical sunrise, as HH:MM:SS.
  final String sunrise;

  /// Solar noon (exact geometric transit), as HH:MM:SS.
  final String noon;

  /// Dhuhr (2.5 minutes after solar noon), as HH:MM:SS.
  final String dhuhr;

  /// Asr (Shafi'i or Hanafi shadow convention), as HH:MM:SS.
  final String asr;

  /// Maghrib (sunset), as HH:MM:SS.
  final String maghrib;

  /// Isha (nightfall, end of shafaq), as HH:MM:SS.
  final String isha;

  /// Dynamic twilight angles used for this calculation.
  final TwilightAngles angles;

  const FormattedPrayerTimes({
    required this.qiyam,
    required this.fajr,
    required this.sunrise,
    required this.noon,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.angles,
  });
}

/// Solar ephemeris result.
class SolarEphemeris {
  /// Solar declination in degrees.
  final double decl;

  /// Earth-Sun distance in AU.
  final double r;

  /// Apparent solar ecliptic longitude in radians (0–2π).
  final double eclLon;

  const SolarEphemeris({
    required this.decl,
    required this.r,
    required this.eclLon,
  });
}

// SpaResult and SpaAnglesResult are provided by the nrel_spa package.
