/// Core prayer times computation — PrayCalc Dynamic Method.
///
/// Returns all prayer times as fractional hours using the dynamic twilight
/// angle algorithm. Times are in local time as determined by the UTC offset.
library;

import 'package:nrel_spa/nrel_spa.dart';

import 'types.dart';
import 'solar_ephemeris.dart';
import 'angles.dart';
import 'asr.dart';
import 'qiyam.dart';
import 'high_latitude.dart';

/// Compute prayer times for a given date and location.
///
/// [date] is the observer's local date (time-of-day is ignored).
/// [lat] is latitude in decimal degrees (−90 to 90, south = negative).
/// [lng] is longitude in decimal degrees (−180 to 180, west = negative).
/// [tz] is UTC offset in hours (e.g., −5 for EST).
/// [elevation] is observer elevation in meters (default: 0).
/// [temperature] is ambient temperature in °C (default: 15).
/// [pressure] is atmospheric pressure in mbar/hPa (default: 1013.25).
/// [hanafi] selects Asr convention: false = Shafi'i/Maliki/Hanbali (default),
/// true = Hanafi.
/// [highLatitudeRule] decides what to do when Fajr or Isha has no observable time
/// (high summer above ~48.5 degrees, or the polar circles). Defaults to
/// [HighLatitudeRule.none]: report them absent and let the caller decide. Any other
/// rule SUBSTITUTES a juristic time; check [PrayerTimes.provenance] to see which times
/// were supplied rather than solved.
PrayerTimes getTimes(
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
  // Normalize to a stable UTC-noon DateTime for this civil calendar date.
  // Reading date.year/month/day directly (without TZ conversion) preserves
  // the caller's expressed date regardless of whether they passed a local or
  // UTC DateTime. Constructing UTC noon removes host-timezone influence from
  // every downstream Julian-Day computation and aligns getSpa with the
  // Meeus/MSC calculations (which all need the same civil date).
  final civDate = DateTime.utc(date.year, date.month, date.day, 12, 0, 0);

  // 1. Compute dynamic twilight angles.
  final tw = getAngles(
    civDate,
    lat,
    lng,
    elevation: elevation,
    temperature: temperature,
    pressure: pressure,
  );

  // 2. Convert depression angles to SPA zenith angles.
  //    SPA uses zenith (90° + depression) for custom altitude events.
  final fajrZenith = 90 + tw.fajrAngle;
  final ishaZenith = 90 + tw.ishaAngle;

  // 3. Run SPA for solar position + custom twilight times.
  //    Pass civDate (UTC noon) so SPA receives a deterministic UTC instant
  //    and the date component it extracts (via date.toUtc()) is always the
  //    intended civil day, independent of host timezone.
  final spaData = getSpa(
    civDate,
    lat,
    lng,
    tz,
    elevation: elevation,
    temperature: temperature,
    pressure: pressure,
    customAngles: [fajrZenith, ishaZenith],
  );

  final fajrTime = spaData.angles[0].sunrise;
  final sunriseTime = spaData.sunrise;
  final noonTime = spaData.solarNoon;
  final maghribTime = spaData.sunset;
  final ishaTime = spaData.angles[1].sunset;

  // Dhuhr: 2.5 minutes after solar noon.
  final dhuhrTime = noonTime + 2.5 / 60;

  // 4. Solar declination for Asr (Meeus formula, accurate to ~0.01°).
  //    civDate already is UTC noon of the civil date.
  final jd = toJulianDate(civDate);
  final eph = solarEphemeris(jd);

  // 5. Asr time.
  final asrTime = getAsr(noonTime, lat, eph.decl, hanafi: hanafi);

  // 6. High-latitude substitution. Astronomically solved times pass through untouched;
  //    only genuinely absent ones are supplied, and only by the requested rule.
  final highLat = applyHighLatitudeRule(
    HighLatitudeContext(
      rule: highLatitudeRule,
      date: date,
      lat: lat,
      lng: lng,
      fajrAngle: tw.fajrAngle,
      ishaAngle: tw.ishaAngle,
      // Resolving another day or latitude must not recurse into the rule itself.
      resolveDay: (d, resolveLat, resolveLng) {
        final r = getTimes(
          d, resolveLat, resolveLng, tz,
          elevation: elevation, temperature: temperature, pressure: pressure,
          hanafi: hanafi, highLatitudeRule: HighLatitudeRule.none,
        );
        return ResolvedDay(fajr: r.fajr, isha: r.isha, noon: r.noon);
      },
    ),
    fajrTime,
    ishaTime,
    sunriseTime,
    maghribTime,
  );

  // 7. Qiyam al-Layl follows from the resolved Fajr/Isha, so an enabled rule carries
  //    through to it as well.
  final qiyamTime = getQiyam(highLat.fajr, highLat.isha);

  return PrayerTimes(
    qiyam: qiyamTime.isFinite ? qiyamTime : double.nan,
    fajr: highLat.fajr.isFinite ? highLat.fajr : double.nan,
    sunrise: sunriseTime.isFinite ? sunriseTime : double.nan,
    noon: noonTime.isFinite ? noonTime : double.nan,
    dhuhr: dhuhrTime.isFinite ? dhuhrTime : double.nan,
    asr: asrTime.isFinite ? asrTime : double.nan,
    maghrib: maghribTime.isFinite ? maghribTime : double.nan,
    isha: highLat.isha.isFinite ? highLat.isha : double.nan,
    angles: tw,
    provenance: highLat.provenance,
  );
}

/// Format fractional hours as HH:MM:SS string.
/// Returns "N/A" if the value is non-finite or negative.
String formatTime(double hours) {
  if (!hours.isFinite || hours < 0) return 'N/A';
  final totalSec = (hours * 3600).round();
  final h = (totalSec ~/ 3600) % 24;
  final rem = totalSec - (totalSec ~/ 3600) * 3600;
  final m = rem ~/ 60;
  final s = rem - m * 60;
  return '${h.toString().padLeft(2, '0')}:'
      '${m.toString().padLeft(2, '0')}:'
      '${s.toString().padLeft(2, '0')}';
}
