# Quickstart

## Install

Add to `pubspec.yaml`:

```yaml
dependencies:
  pray_calc_dart: ^1.0.0
```

Run `dart pub get`.

## First Call

```dart
import 'package:pray_calc_dart/pray_calc_dart.dart';

void main() {
  final times = getTimes(
    DateTime.utc(2024, 3, 15),
    21.3891,  // Makkah latitude
    39.8579,  // longitude
    3.0,      // UTC offset (Arabia Standard Time)
  );

  print('Fajr:    ${times.fajr.toStringAsFixed(4)} h');
  print('Dhuhr:   ${times.dhuhr.toStringAsFixed(4)} h');
  print('Asr:     ${times.asr.toStringAsFixed(4)} h');
  print('Maghrib: ${times.maghrib.toStringAsFixed(4)} h');
  print('Isha:    ${times.isha.toStringAsFixed(4)} h');
}
```

## Output Fields

`getTimes` returns a `PrayerTimes` object:

| Field | Type | Description |
| --- | --- | --- |
| `fajr` | `double` | Fajr time (decimal hours, local) |
| `dhuhr` | `double` | Dhuhr time |
| `asr` | `double` | Asr time |
| `maghrib` | `double` | Maghrib time (sunset) |
| `isha` | `double` | Isha time |
| `midnight` | `double` | Islamic midnight |
| `qiyam` | `double` | Last third of night start |

All times are decimal hours in the local timezone defined by `utcOffset`.

## Converting to DateTime

```dart
DateTime timeToDateTime(DateTime date, double hours, double utcOffset) {
  final totalMinutes = (hours * 60).round();
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  return DateTime(date.year, date.month, date.day, h, m)
    .subtract(Duration(hours: utcOffset.truncate(), minutes: ((utcOffset % 1) * 60).round()));
}
```
