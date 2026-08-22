/// Core types for pray_calc_dart.
library;

import 'high_latitude.dart';

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

  /// Islamic midnight: the midpoint between Maghrib and Fajr. Commonly used as the
  /// endpoint of the Isha window.
  final double midnight;

  /// Dynamic twilight angles used for this calculation.
  final TwilightAngles angles;

  /// Origin of [fajr] and [isha]: observed when solved from the sun's actual position,
  /// the rule name when a high-latitude substitution supplied it, or unavailable when
  /// no observable time exists and no rule was able to supply one.
  ///
  /// Check this before presenting a time as a calculation: above the polar circles a
  /// substituted value is a juristic choice, not an astronomical result.
  final TimeProvenance provenance;

  const PrayerTimes({
    required this.qiyam,
    required this.fajr,
    required this.sunrise,
    required this.noon,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.midnight,
    required this.angles,
    required this.provenance,
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

  /// Islamic midnight, as HH:MM:SS.
  final String midnight;

  /// Dynamic twilight angles used for this calculation.
  final TwilightAngles angles;

  /// Origin of [fajr] and [isha] — see [PrayerTimes.provenance].
  final TimeProvenance provenance;

  const FormattedPrayerTimes({
    required this.qiyam,
    required this.fajr,
    required this.sunrise,
    required this.noon,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.midnight,
    required this.angles,
    required this.provenance,
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

/// One method's comparison result: its Fajr and Isha for the requested day.
///
/// A method whose depression angle the sun never reaches on this date reports NaN rather
/// than a substituted value. That is deliberate: the comparison map exists to show which
/// methods are applicable where, so a method with no answer must keep saying so. Use
/// [PrayerTimes.fajr]/[PrayerTimes.isha] with a [HighLatitudeRule] when you need a time
/// to display.
class MethodEntry {
  /// Fajr in fractional hours, or NaN when this method cannot reach dawn today.
  final double fajr;

  /// Isha in fractional hours, or NaN when this method cannot reach nightfall today.
  final double isha;

  const MethodEntry(this.fajr, this.isha);

  @override
  String toString() => 'MethodEntry($fajr, $isha)';
}

/// Dynamic-method prayer times plus a comparison entry for every supported method.
class PrayerTimesAll {
  /// Qiyam al-Layl (last third of the night).
  final double qiyam;

  /// Fajr (dawn).
  final double fajr;

  /// Sunrise, and the end of the Fajr window.
  final double sunrise;

  /// Solar noon (transit).
  final double noon;

  /// Dhuhr (just after solar transit).
  final double dhuhr;

  /// Asr (afternoon).
  final double asr;

  /// Maghrib (sunset).
  final double maghrib;

  /// Isha (nightfall).
  final double isha;

  /// Islamic midnight (midpoint between Maghrib and Fajr).
  final double midnight;

  /// Dynamic twilight angles used for the primary times.
  final TwilightAngles angles;

  /// Origin of Fajr and Isha — see [PrayerTimes.provenance].
  final TimeProvenance provenance;

  /// Comparison results keyed by method id (`'MWL'`, `'ISNA'`, ...).
  final Map<String, MethodEntry> methods;

  const PrayerTimesAll({
    required this.qiyam,
    required this.fajr,
    required this.sunrise,
    required this.noon,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.midnight,
    required this.angles,
    required this.provenance,
    required this.methods,
  });
}

/// [PrayerTimesAll] with every time rendered as an HH:MM:SS string.
class FormattedPrayerTimesAll {
  final String qiyam;
  final String fajr;
  final String sunrise;
  final String noon;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String midnight;

  /// Dynamic twilight angles used for the primary times.
  final TwilightAngles angles;

  /// Origin of Fajr and Isha — see [PrayerTimes.provenance].
  final TimeProvenance provenance;

  /// Formatted comparison times per method: `[fajrString, ishaString]`.
  final Map<String, List<String>> methods;

  const FormattedPrayerTimesAll({
    required this.qiyam,
    required this.fajr,
    required this.sunrise,
    required this.noon,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.midnight,
    required this.angles,
    required this.provenance,
    required this.methods,
  });
}
