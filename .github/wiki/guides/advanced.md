# Advanced Usage

## Madhab Selection

The Asr time differs between the Hanafi and standard (Shafi'i/Maliki/Hanbali) methods:

```dart
import 'package:pray_calc_dart/pray_calc_dart.dart';

final standard = getTimes(
  DateTime.utc(2024, 3, 15),
  40.7128, -74.0060, -5.0,
  config: const PrayerConfig(madhab: Madhab.standard),
);

final hanafi = getTimes(
  DateTime.utc(2024, 3, 15),
  40.7128, -74.0060, -5.0,
  config: const PrayerConfig(madhab: Madhab.hanafi),
);

print('Asr (standard): ${standard.asr.toStringAsFixed(4)} h');
print('Asr (Hanafi):   ${hanafi.asr.toStringAsFixed(4)} h');
```

## MCW Seasonal Model

The MCW (Mohammed Camille Widad) seasonal model adjusts Fajr and Isha depression angles across the year to match observed sighting data. This is the default behavior. The DPC (Dynamic Prayer Calculation) variant uses ML-calibrated angles derived from verified sighting observations.

Both models are used automatically based on latitude and date. No configuration is needed.

## Fixed Angle Override

For interoperability with fixed-angle calculation methods (ISNA, MWL, etc.):

```dart
final times = getTimes(
  DateTime.utc(2024, 3, 15),
  40.7128, -74.0060, -5.0,
  config: const PrayerConfig(
    fajrAngle: 15.0,   // ISNA
    ishaAngle: 15.0,
  ),
);
```

## High Latitude Adjustments

At latitudes above 48°N or below 48°S, Fajr and Isha times may behave unusually due to near-continuous twilight. The library applies the Middle of Night method automatically for extreme latitudes. Check `times.fajr.isNaN` to detect fallback conditions.
