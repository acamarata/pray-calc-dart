# Flutter Integration

This example shows how to use `pray_calc_dart` in a Flutter widget. It reads the device's current location using `geolocator` and displays the current prayer times for that location.

## Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  pray_calc_dart: ^1.0.0
  geolocator: ^14.0.0
```

## PrayerTimesCard Widget

```dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pray_calc_dart/pray_calc_dart.dart';

class PrayerTimesCard extends StatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  State<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends State<PrayerTimesCard> {
  PrayerTimes? _times;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTimes();
  }

  Future<void> _loadTimes() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _error = 'Location permission denied.');
        return;
      }

      final pos = await Geolocator.getCurrentPosition();

      // UTC offset in hours — derive from the device's local time.
      final utcOffset =
          DateTime.now().timeZoneOffset.inMinutes / 60.0;

      final times = getTimes(
        DateTime.now(),
        pos.latitude,
        pos.longitude,
        utcOffset,
      );

      setState(() => _times = times);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Text('Error: $_error');
    }
    if (_times == null) {
      return const CircularProgressIndicator();
    }

    final rows = [
      ('Fajr', _times!.fajr),
      ('Sunrise', _times!.sunrise),
      ('Dhuhr', _times!.dhuhr),
      ('Asr', _times!.asr),
      ('Maghrib', _times!.maghrib),
      ('Isha', _times!.isha),
      ('Qiyam', _times!.qiyam),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows.map((r) {
            final (name, hours) = r;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(formatTime(hours)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
```

## Notes

- `getTimes` is a pure synchronous function. Only the location request is async.
- Pass `hanafi: true` to `getTimes` for the Hanafi Asr convention (shadow factor 2 instead of 1).
- `formatTime` returns `'N/A'` for unreachable events (polar nights). Handle this in the UI if targeting high-latitude users.
- For production use, cache the result and re-compute once per day or on location change. Prayer times change by only a few minutes per day at most latitudes.
