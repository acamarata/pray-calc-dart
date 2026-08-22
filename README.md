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

  // Or get them already formatted.
  final f = calcTimes(date, 40.7128, -74.0060, -5.0);
  print('Isha: ${f.isha}  Midnight: ${f.midnight}');
}
```

### Comparing against a specific authority

The default is the dynamic method. When you need to match a published timetable, ask for
every method at once and pick the one you need:

```dart
final all = calcTimesAll(DateTime(2024, 3, 15), 40.7128, -74.0060, -5.0);

print(all.fajr);                 // dynamic method
print(all.methods['MWL']![0]);   // Muslim World League Fajr
print(all.methods['ISNA']![1]);  // ISNA Isha

for (final m in kMethods) {
  print('${m.id.padRight(8)} ${m.name}');
}
```

A method that cannot reach its depression angle where and when you asked reports `'N/A'`
rather than a substituted time — above roughly 48.5 degrees the sun stops reaching 18
degrees below the horizon in summer, so an 18-degree method simply has no answer there.
That is the point of the map: it shows you which methods are applicable. To get a
displayable time in those conditions, use `highLatitudeRule` with the primary times.

## API

Full API documentation, guides, and examples are in the [wiki](https://github.com/acamarata/pray-calc-dart/wiki).

### Core functions

| Function | Description |
| --- | --- |
| `getTimes(date, lat, lng, tz, {...})` | All prayer times for a date and location, as fractional hours |
| `calcTimes(date, lat, lng, tz, {...})` | The same, formatted as `HH:MM:SS` strings |
| `getTimesAll(date, lat, lng, tz, {...})` | Adds a comparison entry for all fourteen traditional methods |
| `calcTimesAll(date, lat, lng, tz, {...})` | The same, formatted as `HH:MM:SS` strings |
| `kMethods` | The method table: id, name, region, angles |
| `getAngles(date, lat, lng, {...})` | Dynamic Fajr/Isha depression angles |
| `getMidnight(maghrib, fajr)` | Midpoint of the night |
| `applyHighLatitudeRule(...)` | Fajr/Isha substitution where no observable time exists |
| `getSpa(date, lat, lng, tz, {...})` | NREL Solar Position Algorithm (re-export) |
| `formatTime(hours)` | Fractional hours to `HH:MM:SS` string |

## Dynamic Angle Algorithm

Fixed-angle methods (ISNA 15 degrees, MWL 18 degrees) produce inaccurate Fajr times at latitudes above 45 degrees N/S. The dynamic method adapts the depression angle based on season, latitude, Earth-Sun distance, and local atmospheric conditions.

Result: approximately 18 degrees at the equator, approximately 12-14 degrees at 50-55 degrees N in summer. Matches observational data from the Moonsighting Committee Worldwide.


## High latitudes

Above roughly 48.5 degrees the sun stops reaching 18 degrees below the horizon in summer,
and inside the polar circles it stops rising or setting at all for weeks. There is then no
observable dawn or nightfall, so Fajr and Isha have no calculable time.

By default this package reports them as absent (`double.nan`, formatted `"N/A"`) rather
than substituting a value, because every substitution is a juristic position rather than
an astronomical result:

```dart
final t = getTimes(DateTime.utc(2026, 6, 21), 78.22334, 15.64689, 1.0);
// t.fajr.isNaN == true
// t.provenance.fajr == TimeSource.unavailable
// t.dhuhr and t.asr are still real times
```

Six opt-in rules are available via `highLatitudeRule`:

| Rule | Needs a real sunset | Covers the polar circles |
|---|---|---|
| `none` (default) | no | reports absent |
| `middleOfNight` | yes | no |
| `oneSeventh` | yes | no |
| `angleBased` | yes | no |
| `aqrabAlBilad` (nearest latitude, 45th parallel) | no | yes |
| `aqrabAlAyyam` (nearest date) | no | yes |

```dart
final t = getTimes(
  DateTime.utc(2026, 6, 21), 78.22334, 15.64689, 1.0,
  highLatitudeRule: HighLatitudeRule.aqrabAlBilad,
);
// t.provenance.fajr == TimeSource.aqrabAlBilad
```

The three night-proportion rules divide the span between sunset and sunrise, so inside the
polar circles they have nothing to measure and correctly decline to invent a time. Only
the two nearest-substitution rules cover those latitudes.

`provenance` names the origin of Fajr and Isha on every result, so a substituted time is
never mistaken for a computed one.

Dhuhr and Asr remain available every day at every latitude: the sun crosses the local
meridian even on days it never rises. Inside the polar circles during winter that crossing
happens below the horizon, so those times are astronomically real but not observable.

### Twilight angle range

The dynamic angle is clamped to 10-22 degrees. Above roughly 70 degrees it sits at the
10-degree floor, outside the latitude span the Moonsighting Committee data was fitted to.
Treat results there as the edge of the model's validated range.

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
