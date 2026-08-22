/// Formatted prayer times — dynamic method plus every traditional method comparison.
library;

import 'get_times.dart' show formatTime;
import 'get_times_all.dart';
import 'high_latitude.dart';
import 'types.dart';

/// Compute prayer times formatted as HH:MM:SS strings, plus formatted comparison times
/// for every supported traditional method.
///
/// A thin formatting layer over [getTimesAll]; see it for full parameter documentation.
/// A method that cannot reach dawn or nightfall at this location today renders as `'N/A'`.
///
/// ```dart
/// final result = calcTimesAll(DateTime(2024, 6, 21), 40.7128, -74.006, -4);
/// print(result.fajr);              // dynamic method
/// print(result.methods['ISNA']![0]); // ISNA's Fajr
/// ```
FormattedPrayerTimesAll calcTimesAll(
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
  final raw = getTimesAll(
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

  final methods = <String, List<String>>{};
  for (final entry in raw.methods.entries) {
    methods[entry.key] = [
      formatTime(entry.value.fajr),
      formatTime(entry.value.isha),
    ];
  }

  return FormattedPrayerTimesAll(
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
    methods: methods,
  );
}
