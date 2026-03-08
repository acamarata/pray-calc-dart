# pray_calc_dart

Islamic prayer times for Dart and Flutter. Implements the MCW seasonal model and dynamic twilight angles. Uses [nrel_spa](https://pub.dev/packages/nrel_spa) for the NREL Solar Position Algorithm.

## Quick Start

```dart
import 'package:pray_calc_dart/pray_calc_dart.dart';

final times = getTimes(DateTime(2024, 3, 15), 40.7128, -74.0060, -5.0);
print('Fajr:    ${formatTime(times.fajr)}');
print('Dhuhr:   ${formatTime(times.dhuhr)}');
print('Maghrib: ${formatTime(times.maghrib)}');
print('Isha:    ${formatTime(times.isha)}');
```

## Pages

- [API Reference](API-Reference) — Full function and type reference
- [Dynamic Angle Algorithm](Dynamic-Algorithm) — Physics-grounded twilight angle computation
