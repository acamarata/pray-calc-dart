# Basic Usage Examples

## Daily Prayer Times for Multiple Cities

```dart
import 'package:pray_calc_dart/pray_calc_dart.dart';

void printPrayers(String city, double lat, double lng, double utcOffset) {
  final times = getTimes(DateTime.utc(2024, 3, 15), lat, lng, utcOffset);

  String fmt(double h) {
    if (h.isNaN) return '--:--';
    final hh = h.truncate();
    final mm = ((h - hh) * 60).round();
    return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
  }

  print('$city');
  print('  Fajr:    ${fmt(times.fajr)}');
  print('  Dhuhr:   ${fmt(times.dhuhr)}');
  print('  Asr:     ${fmt(times.asr)}');
  print('  Maghrib: ${fmt(times.maghrib)}');
  print('  Isha:    ${fmt(times.isha)}');
}

void main() {
  printPrayers('Makkah',   21.3891,  39.8579,  3.0);
  printPrayers('Istanbul', 41.0082,  28.9784,  3.0);
  printPrayers('London',   51.5074,  -0.1278,  0.0);
  printPrayers('New York', 40.7128, -74.0060, -5.0);
}
```

## Monthly Calendar

```dart
import 'package:pray_calc_dart/pray_calc_dart.dart';

void main() {
  const lat = 40.7128;
  const lng = -74.0060;
  const utcOffset = -5.0;

  print('Date,Fajr,Dhuhr,Asr,Maghrib,Isha');
  for (int day = 1; day <= 30; day++) {
    final date = DateTime.utc(2024, 3, day);
    final t = getTimes(date, lat, lng, utcOffset);

    String h(double v) => v.toStringAsFixed(4);
    print('2024-03-${day.toString().padLeft(2, "0")},${h(t.fajr)},${h(t.dhuhr)},${h(t.asr)},${h(t.maghrib)},${h(t.isha)}');
  }
}
```
