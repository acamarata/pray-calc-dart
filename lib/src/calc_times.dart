/// Formatted prayer times using the PrayCalc Dynamic Method.
library;

import 'get_times.dart';
import 'high_latitude.dart';
import 'types.dart';

/// Compute prayer times formatted as HH:MM:SS strings.
///
/// A thin formatting layer over [getTimes]; see it for full parameter documentation.
/// Any time that cannot be computed (polar night, an unreachable depression angle, a
/// high-latitude rule that does not apply here) renders as `'N/A'` rather than a
/// fabricated clock reading.
///
/// Note that a time past midnight renders on a 24-hour clock — an Isha of 24.163 becomes
/// `'00:09:46'`. Check [PrayerTimes.isha] against [PrayerTimes.maghrib] on the raw result
/// if you need to know which calendar day a time belongs to.
///
/// ```dart
/// final times = calcTimes(DateTime(2024, 6, 21), 40.7128, -74.006, -4);
/// print(times.fajr);    // 03:51:24
/// print(times.maghrib); // 20:31:17
/// ```
FormattedPrayerTimes calcTimes(
  DateTime date,
  double lat,
  double lng,
  double tz, {
  double elevation = 0,
  double temperature = 15,
  double pressure = 1013.25,
  bool hanafi = false,
  HighLatitudeRule highLatitudeRule = HighLatitudeRule.none,
}) {
  final raw = getTimes(
    date,
    lat,
    lng,
    tz,
    elevation: elevation,
    temperature: temperature,
    pressure: pressure,
    hanafi: hanafi,
    highLatitudeRule: highLatitudeRule,
  );

  return FormattedPrayerTimes(
    qiyam: formatTime(raw.qiyam),
    fajr: formatTime(raw.fajr),
    sunrise: formatTime(raw.sunrise),
    noon: formatTime(raw.noon),
    dhuhr: formatTime(raw.dhuhr),
    asr: formatTime(raw.asr),
    maghrib: formatTime(raw.maghrib),
    isha: formatTime(raw.isha),
    midnight: formatTime(raw.midnight),
    angles: raw.angles,
    provenance: raw.provenance,
  );
}
