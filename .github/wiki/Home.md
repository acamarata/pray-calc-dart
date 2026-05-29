# pray_calc_dart

Islamic prayer times for Dart and Flutter. Calculates Fajr, Dhuhr, Asr, Maghrib, Isha, midnight, and Qiyam for any date and location. Implements the MCW seasonal model and Dynamic Prayer Calculation (DPC) algorithm. Depends on `nrel_spa` for solar positioning.

## Install

```yaml
dependencies:
  pray_calc_dart: ^1.0.0
```

```dart
import 'package:pray_calc_dart/pray_calc_dart.dart';

final times = getTimes(
  DateTime.utc(2024, 3, 15),
  21.3891,   // Makkah latitude
  39.8579,   // longitude
  3.0,       // UTC offset (AST)
);

print('Fajr:    ${times.fajr.toStringAsFixed(4)} h');
print('Dhuhr:   ${times.dhuhr.toStringAsFixed(4)} h');
print('Maghrib: ${times.maghrib.toStringAsFixed(4)} h');
print('Isha:    ${times.isha.toStringAsFixed(4)} h');
```

## Contents

- [Quickstart Guide](guides/quickstart) — install, first call, config options
- [Advanced Usage](guides/advanced) — madhab, custom angles, seasonal model
- [API Reference](API-Reference) — full function and type reference
- [Examples](examples/basic-usage) — real-world snippets
- [Contributing](CONTRIBUTING)
