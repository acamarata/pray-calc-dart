# pray_calc_dart

[![pub package](https://img.shields.io/pub/v/pray_calc_dart.svg)](https://pub.dev/packages/pray_calc_dart)
[![CI](https://github.com/acamarata/pray-calc-dart/actions/workflows/ci.yml/badge.svg)](https://github.com/acamarata/pray-calc-dart/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Islamic prayer times for Dart and Flutter. Pure Dart port of [pray-calc](https://github.com/acamarata/pray-calc), implementing the MCW seasonal model and dynamic twilight angles. Uses [nrel_spa](https://github.com/acamarata/nrel-spa-dart) for the NREL Solar Position Algorithm.

## Installation

```yaml
dependencies:
  pray_calc_dart: ^1.0.0
```

## Quick Start

```dart
import 'package:pray_calc_dart/pray_calc_dart.dart';

void main() {
  final date = DateTime(2024, 3, 15);
  final times = getTimes(date, 40.7128, -74.0060, -5.0);

  print('Fajr:    ${formatTime(times.fajr)}');
  print('Sunrise: ${formatTime(times.sunrise)}');
  print('Dhuhr:   ${formatTime(times.dhuhr)}');
  print('Asr:     ${formatTime(times.asr)}');
  print('Maghrib: ${formatTime(times.maghrib)}');
  print('Isha:    ${formatTime(times.isha)}');
  print('Qiyam:   ${formatTime(times.qiyam)}');
}
```

## API

### `getTimes(date, lat, lng, tz, {elevation, temperature, pressure, hanafi})`

Computes all prayer times for a given date and location.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `date` | `DateTime` | required | Local date (time-of-day ignored) |
| `lat` | `double` | required | Latitude (-90 to 90, south negative) |
| `lng` | `double` | required | Longitude (-180 to 180, west negative) |
| `tz` | `double` | required | UTC offset in hours (e.g., -5 for EST) |
| `elevation` | `double` | 0 | Observer elevation in meters |
| `temperature` | `double` | 15 | Ambient temperature in Celsius |
| `pressure` | `double` | 1013.25 | Atmospheric pressure in mbar |
| `hanafi` | `bool` | false | Hanafi Asr (2x shadow) vs Shafi'i (1x) |

Returns a `PrayerTimes` object with fractional-hour values for: `qiyam`, `fajr`, `sunrise`, `noon`, `dhuhr`, `asr`, `maghrib`, `isha`, and the computed `angles`.

### `getAngles(date, lat, lng, {elevation, temperature, pressure})`

Computes dynamic twilight depression angles using the three-layer model:

1. MCW seasonal base (piecewise-linear, latitude-dependent)
2. Ephemeris corrections (Earth-Sun distance, Fourier season smoothing)
3. Environmental corrections (elevation dip, atmospheric refraction)

Returns `TwilightAngles` with `fajrAngle` and `ishaAngle` in degrees, clipped to [10, 22].

### `getSpa(date, lat, lng, tz, {...})`

Full NREL Solar Position Algorithm. Accurate to +/-0.0003 degrees for zenith angle. Supports custom zenith angles for twilight calculations.

### `formatTime(hours)`

Converts fractional hours to an `HH:MM:SS` string. Returns `"N/A"` for non-finite values.

### Additional Functions

- `solarEphemeris(jd)` -- Jean Meeus Ch. 25 low-precision ephemeris
- `toJulianDate(date)` -- DateTime to Julian Date
- `getAsr(solarNoon, latitude, declination, {hanafi})` -- Asr computation
- `getQiyam(fajrTime, ishaTime)` -- Last third of the night
- `getMscFajr(date, latitude)` -- MCW Fajr offset in minutes
- `getMscIsha(date, latitude, [shafaq])` -- MCW Isha offset in minutes
- `minutesToDepression(minutes, latDeg, declDeg)` -- Time to angle conversion

## Dynamic Angle Algorithm

Fixed-angle methods (ISNA 15 degrees, MWL 18 degrees, etc.) produce inaccurate Fajr times at latitudes above 45 degrees N/S. The dynamic method adapts the depression angle based on season, latitude, Earth-Sun distance, and local atmospheric conditions.

Result: approximately 18 degrees at the equator, approximately 12-14 degrees at 50-55 degrees N in summer. Matches observational data from the Moonsighting Committee Worldwide.

## Architecture

Built in three layers: (1) [nrel_spa](https://pub.dev/packages/nrel_spa) provides the solar ephemeris foundation; (2) the MSC piecewise model computes seasonal minute offsets which are converted to depression angles via spherical trigonometry; (3) physics corrections (Earth-Sun distance, refraction, elevation dip) adjust the angle within [10°, 22°] bounds.

## Compatibility

Dart SDK 3.7.0+. Works in Flutter (iOS, Android, Web, Desktop), Dart CLI, and server-side Dart. Single dependency: [nrel_spa](https://pub.dev/packages/nrel_spa).

## Related

- [pray-calc](https://github.com/acamarata/pray-calc) - TypeScript/JavaScript version (npm)
- [nrel-spa](https://github.com/acamarata/nrel-spa) - Standalone NREL SPA for JavaScript
- [qibla](https://github.com/acamarata/qibla) - Qibla direction calculator

## Acknowledgments

The Solar Position Algorithm is based on:

> Reda, I. and Andreas, A. (2004). Solar Position Algorithm for Solar Radiation Applications. NREL/TP-560-34302. [DOI: 10.2172/15003974](https://doi.org/10.2172/15003974)

The MCW seasonal model is based on the work of the [Moonsighting Committee Worldwide](http://moonsighting.com/isha_fajr.html) (Khalid Shaukat).

## License

[MIT](LICENSE). The NREL SPA implementation carries its own terms (see LICENSE for details).
