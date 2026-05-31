# pray_calc_dart

[![pub package](https://img.shields.io/pub/v/pray_calc_dart.svg)](https://pub.dev/packages/pray_calc_dart)
[![CI](https://github.com/acamarata/pray-calc-dart/actions/workflows/ci.yml/badge.svg)](https://github.com/acamarata/pray-calc-dart/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Wiki](https://img.shields.io/badge/docs-wiki-blue)](https://github.com/acamarata/pray-calc-dart/wiki)

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

Full API documentation, guides, and examples are in the [wiki](https://github.com/acamarata/pray-calc-dart/wiki).

### Core functions

| Function | Description |
| --- | --- |
| `getTimes(date, lat, lng, tz, {...})` | All prayer times for a date and location |
| `getAngles(date, lat, lng, {...})` | Dynamic Fajr/Isha depression angles |
| `getSpa(date, lat, lng, tz, {...})` | NREL Solar Position Algorithm (re-export) |
| `formatTime(hours)` | Fractional hours to `HH:MM:SS` string |

## Dynamic Angle Algorithm

Fixed-angle methods (ISNA 15 degrees, MWL 18 degrees) produce inaccurate Fajr times at latitudes above 45 degrees N/S. The dynamic method adapts the depression angle based on season, latitude, Earth-Sun distance, and local atmospheric conditions.

Result: approximately 18 degrees at the equator, approximately 12-14 degrees at 50-55 degrees N in summer. Matches observational data from the Moonsighting Committee Worldwide.

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
