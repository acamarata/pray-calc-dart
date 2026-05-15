# API Reference

## getTimes

```dart
PrayerTimes getTimes(
  DateTime date,
  double lat,
  double lng,
  double tz, {
  double elevation = 0,
  double temperature = 15,
  double pressure = 1013.25,
  bool hanafi = false,
})
```

Computes all prayer times for a given date and location.

### Parameters

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `date` | `DateTime` | required | Local date (time-of-day ignored) |
| `lat` | `double` | required | Latitude (-90 to 90, south negative) |
| `lng` | `double` | required | Longitude (-180 to 180, west negative) |
| `tz` | `double` | required | UTC offset in hours (e.g., -5 for EST) |
| `elevation` | `double` | 0 | Observer elevation in meters |
| `temperature` | `double` | 15 | Ambient temperature in Celsius |
| `pressure` | `double` | 1013.25 | Atmospheric pressure in mbar |
| `hanafi` | `bool` | false | Hanafi Asr (2x shadow ratio) vs Shafi'i (1x) |

### PrayerTimes fields

All time values are fractional hours in local time.

| Field | Type | Description |
| --- | --- | --- |
| `qiyam` | `double` | Last third of the night (between Isha and Fajr) |
| `fajr` | `double` | Dawn prayer |
| `sunrise` | `double` | Sunrise |
| `noon` | `double` | True solar noon |
| `dhuhr` | `double` | Midday prayer (solar noon + small offset) |
| `asr` | `double` | Afternoon prayer |
| `maghrib` | `double` | Sunset prayer |
| `isha` | `double` | Night prayer |
| `angles` | `TwilightAngles` | The computed dynamic angles used for Fajr/Isha |

---

## getAngles

```dart
TwilightAngles getAngles(
  DateTime date,
  double lat,
  double lng, {
  double elevation = 0,
  double temperature = 15,
  double pressure = 1013.25,
})
```

Computes dynamic twilight depression angles using the three-layer model:

1. MCW seasonal base (piecewise-linear, latitude-dependent)
2. Ephemeris corrections (Earth-Sun distance, Fourier season smoothing)
3. Environmental corrections (elevation dip, atmospheric refraction)

### TwilightAngles fields

| Field | Type | Description |
| --- | --- | --- |
| `fajrAngle` | `double` | Fajr depression angle (degrees, clipped to [10, 22]) |
| `ishaAngle` | `double` | Isha depression angle (degrees, clipped to [10, 22]) |

---

## getSpa

```dart
SpaResult getSpa(
  DateTime date,
  double lat,
  double lng,
  double tz, {
  double elevation = 0,
  double temperature = 15,
  double pressure = 1013.25,
  List<double> customAngles = const [],
})
```

Full NREL Solar Position Algorithm. Accurate to +/- 0.0003 degrees for zenith angle. Supports custom zenith angles for twilight calculations. This is a re-export from [nrel_spa](https://pub.dev/packages/nrel_spa).

---

## formatTime

```dart
String formatTime(double hours)
```

Converts a fractional-hour value to an `HH:MM:SS` string. Returns `"N/A"` for non-finite values (e.g., no sunrise at extreme latitudes).

```dart
print(formatTime(5.75));  // "05:45:00"
print(formatTime(18.5));  // "18:30:00"
```

---

## Additional Functions

| Function | Description |
| --- | --- |
| `solarEphemeris(double jd)` | Jean Meeus Ch. 25 low-precision solar ephemeris |
| `toJulianDate(DateTime date)` | Convert a DateTime to Julian Date |
| `getAsr(double solarNoon, double latitude, double declination, {bool hanafi})` | Compute Asr time |
| `getQiyam(double fajrTime, double ishaTime)` | Compute the last third of the night |
| `getMscFajr(DateTime date, double latitude)` | MCW Fajr seasonal offset in minutes |
| `getMscIsha(DateTime date, double latitude, [String shafaq])` | MCW Isha seasonal offset in minutes |
| `minutesToDepression(double minutes, double latDeg, double declDeg)` | Convert time offset to solar depression angle |

---

[Home](Home)
