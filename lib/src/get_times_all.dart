/// Prayer times comparison — dynamic method plus every traditional method.
///
/// Returns the PrayCalc Dynamic times together with a comparison entry for each of the
/// fourteen supported methods, all as fractional hours. See [kMethods] for the table.
///
/// The comparison entries are deliberately NOT put through the high-latitude rule. The
/// primary Fajr/Isha are, because those are what a caller displays; the per-method entries
/// exist to answer "which methods work here", and a method that cannot produce a time at
/// this location on this date must keep saying so rather than borrowing one.
library;

import 'package:nrel_spa/nrel_spa.dart';

import 'angles.dart';
import 'asr.dart';
import 'constants.dart';
import 'get_times.dart';
import 'high_latitude.dart';
import 'methods.dart';
import 'midnight.dart';
import 'msc.dart';
import 'qiyam.dart';
import 'solar_ephemeris.dart';
import 'types.dart';

/// Compute the dynamic prayer times plus a comparison entry for every method in [kMethods].
///
/// Parameters match [getTimes] exactly; see it for full documentation.
///
/// A single SPA run covers all methods: the zenith list is built with the dynamic pair
/// first, then two entries per method, so one ephemeris pass answers 30 twilight queries.
PrayerTimesAll getTimesAll(
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
  // Same civil-date normalisation as getTimes: UTC noon removes host-timezone influence
  // from every downstream Julian-Day computation.
  final civDate = DateTime.utc(date.year, date.month, date.day, 12, 0, 0);

  // 1. Dynamic twilight angles.
  final tw = getAngles(
    civDate,
    lat,
    lng,
    elevation: elevation,
    temperature: temperature,
    pressure: pressure,
  );

  // 2. Zenith list: dynamic Fajr/Isha first, then a Fajr/Isha pair per method.
  //    Methods with a null angle (fixed-minute Isha, MSC) get an 18-degree placeholder
  //    whose result is discarded and replaced below.
  final zeniths = <double>[90 + tw.fajrAngle, 90 + tw.ishaAngle];
  for (final m in kMethods) {
    zeniths.add(90 + (m.fajrAngle ?? 18));
    zeniths.add(90 + (m.ishaAngle ?? 18));
  }

  // 3. One SPA pass for everything.
  final spaData = getSpa(
    civDate,
    lat,
    lng,
    tz,
    elevation: elevation,
    temperature: temperature,
    pressure: pressure,
    customAngles: zeniths,
  );

  final fajrTime = spaData.angles[0].sunrise;
  final ishaTime = spaData.angles[1].sunset;
  final sunriseTime = spaData.sunrise;
  final noonTime = spaData.solarNoon;
  final maghribTime = spaData.sunset;
  final dhuhrTime = noonTime + kDhuhrOffsetMinutes / 60;

  // 4. Asr, from the Meeus declination (no extra ephemeris call).
  final eph = solarEphemeris(toJulianDate(civDate));
  final asrTime = getAsr(noonTime, lat, eph.decl, hanafi: hanafi);

  // 5. High-latitude substitution for the primary Fajr/Isha only.
  final highLat = applyHighLatitudeRule(
    HighLatitudeContext(
      rule: highLatitudeRule,
      date: date,
      lat: lat,
      lng: lng,
      fajrAngle: tw.fajrAngle,
      ishaAngle: tw.ishaAngle,
      resolveDay: (d, resolveLat, resolveLng) {
        final r = getTimes(
          d,
          resolveLat,
          resolveLng,
          tz,
          elevation: elevation,
          temperature: temperature,
          pressure: pressure,
          hanafi: hanafi,
          highLatitudeRule: HighLatitudeRule.none,
        );
        return ResolvedDay(fajr: r.fajr, isha: r.isha, noon: r.noon);
      },
    ),
    fajrTime,
    ishaTime,
    sunriseTime,
    maghribTime,
  );

  final qiyamTime = getQiyam(highLat.fajr, highLat.isha);
  final midnightTime = getMidnight(maghribTime, highLat.fajr);

  // 6. Per-method comparison entries.
  final methods = <String, MethodEntry>{};
  for (var i = 0; i < kMethods.length; i++) {
    final m = kMethods[i];
    final base = 2 + i * 2; // this method's slot in the zenith list

    var methodFajr = spaData.angles[base].sunrise;
    double methodIsha;

    if (m.useMsc) {
      // Moonsighting Committee: seasonal minute offsets from sunrise/sunset.
      final mscFajrMin = getMscFajr(civDate, lat);
      final mscIshaMin = getMscIsha(civDate, lat);
      methodFajr =
          sunriseTime.isFinite ? sunriseTime - mscFajrMin / 60 : double.nan;
      methodIsha =
          maghribTime.isFinite ? maghribTime + mscIshaMin / 60 : double.nan;
    } else if (m.ishaMinutes != null) {
      // Fixed-minute Isha (Umm Al-Qura and Qatar: 90 minutes after sunset).
      methodIsha =
          maghribTime.isFinite ? maghribTime + m.ishaMinutes! / 60 : double.nan;
    } else {
      methodIsha = spaData.angles[base + 1].sunset;
    }

    methods[m.id] = MethodEntry(
      methodFajr.isFinite ? methodFajr : double.nan,
      methodIsha.isFinite ? methodIsha : double.nan,
    );
  }

  return PrayerTimesAll(
    qiyam: qiyamTime.isFinite ? qiyamTime : double.nan,
    fajr: highLat.fajr.isFinite ? highLat.fajr : double.nan,
    sunrise: sunriseTime.isFinite ? sunriseTime : double.nan,
    noon: noonTime.isFinite ? noonTime : double.nan,
    dhuhr: dhuhrTime.isFinite ? dhuhrTime : double.nan,
    asr: asrTime.isFinite ? asrTime : double.nan,
    maghrib: maghribTime.isFinite ? maghribTime : double.nan,
    isha: highLat.isha.isFinite ? highLat.isha : double.nan,
    midnight: midnightTime.isFinite ? midnightTime : double.nan,
    angles: tw,
    provenance: highLat.provenance,
    methods: methods,
  );
}
