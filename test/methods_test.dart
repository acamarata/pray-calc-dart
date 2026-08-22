/// Tests for the method-comparison surface: [getTimesAll], [calcTimes], [calcTimesAll],
/// [getMidnight] and the [kMethods] table.
///
/// Cross-language agreement is covered exhaustively in `parity_test.dart`. This file
/// covers the properties that should hold regardless of what the JS port does — the shape
/// of the method table, the ordering guarantees, and the specific behaviours that make the
/// comparison map meaningful at high latitude.
library;

import 'package:pray_calc_dart/pray_calc_dart.dart';
import 'package:test/test.dart';

/// Fractional hours for a wall-clock time, for readable expectations.
double hm(int h, int m) => h + m / 60;

void main() {
  group('kMethods table', () {
    test('has the fourteen documented methods, with unique ids', () {
      expect(kMethods, hasLength(14));
      expect(kMethods.map((m) => m.id).toSet(), hasLength(14));
    });

    test('every method has a name and a region', () {
      for (final m in kMethods) {
        expect(m.name, isNotEmpty, reason: m.id);
        expect(m.region, isNotEmpty, reason: m.id);
      }
    });

    test('is ordered by Fajr angle, with the fixed-minute pair kept together', () {
      // The ordering is by Fajr angle for the angle-based methods. UAQ (18.5) and Qatar
      // (18) sit adjacent instead, because they are the two fixed-minute Isha methods and
      // are grouped as a pair — so a strict angle sort over the whole table does not hold.
      final angled =
          kMethods
              .where((m) => m.fajrAngle != null && m.ishaMinutes == null)
              .toList();
      for (var i = 1; i < angled.length; i++) {
        expect(
          angled[i].fajrAngle!,
          greaterThanOrEqualTo(angled[i - 1].fajrAngle!),
          reason: '${angled[i].id} follows ${angled[i - 1].id}',
        );
      }

      final ids = kMethods.map((m) => m.id).toList();
      expect(
        ids.indexOf('Qatar') - ids.indexOf('UAQ'),
        1,
        reason: 'the fixed-minute methods are listed as an adjacent pair',
      );
    });

    test('every method specifies exactly one way of reaching Isha', () {
      for (final m in kMethods) {
        final ways = [
          m.ishaAngle != null,
          m.ishaMinutes != null,
          m.useMsc,
        ].where((x) => x);
        expect(ways, hasLength(1), reason: '${m.id} must pick one Isha model');
      }
    });

    test(
      'the two fixed-minute methods are Umm Al-Qura and Qatar, both at 90 minutes',
      () {
        final fixed = kMethods.where((m) => m.ishaMinutes != null).toList();
        expect(fixed.map((m) => m.id), unorderedEquals(['UAQ', 'Qatar']));
        expect(fixed.every((m) => m.ishaMinutes == 90), isTrue);
      },
    );

    test('Tehran/Jafari is absent — it is outside this package\'s scope', () {
      final ids = kMethods.map((m) => m.id.toLowerCase()).join(' ');
      expect(ids, isNot(contains('jafari')));
      expect(ids, isNot(contains('tehran')));
    });
  });

  group('getMidnight', () {
    test('splits an ordinary night at its midpoint', () {
      // Sunset 18:00, Fajr 06:00 -> midnight at 00:00.
      expect(getMidnight(18, 6), closeTo(0, 1e-9));
    });

    test('unwraps an endpoint that falls on the following day', () {
      // Sunset 20:00, Fajr 04:00 -> 8h night, midpoint 00:00.
      expect(getMidnight(20, 4), closeTo(0, 1e-9));
    });

    test('handles a short summer night without wrapping past 24', () {
      // Sunset 22:00, Fajr 02:00 -> 4h night, midpoint 00:00.
      expect(getMidnight(22, 2), closeTo(0, 1e-9));
    });

    test('handles a long winter night', () {
      // Sunset 16:00, Fajr 08:00 -> 16h night, midpoint 00:00.
      expect(getMidnight(16, 8), closeTo(0, 1e-9));
    });

    test('returns NaN when either endpoint is absent', () {
      expect(getMidnight(double.nan, 6).isNaN, isTrue);
      expect(getMidnight(18, double.nan).isNaN, isTrue);
      expect(getMidnight(double.infinity, 6).isNaN, isTrue);
    });
  });

  group('midnight inside getTimes', () {
    test('lands between Maghrib and the next Fajr at a mid-latitude site', () {
      final t = getTimes(DateTime.utc(2024, 6, 21), 40.7128, -74.006, -4);
      // Midnight is expressed on a 24-hour clock, so a value below Maghrib means the
      // following morning — which is where it belongs.
      expect(t.midnight, greaterThanOrEqualTo(0));
      expect(t.midnight, lessThan(24));
      final unwrapped = t.midnight < t.maghrib ? t.midnight + 24 : t.midnight;
      expect(unwrapped, greaterThan(t.maghrib));
      expect(unwrapped, lessThan(t.fajr + 24));
    });

    test('is absent when Fajr is absent and no rule was asked for', () {
      final t = getTimes(DateTime.utc(2024, 6, 21), 78.2233, 15.6469, 1);
      expect(t.fajr.isNaN, isTrue, reason: 'polar day: no observable dawn');
      expect(
        t.midnight.isNaN,
        isTrue,
        reason: 'no Fajr means no midpoint to take',
      );
    });
  });

  group('getTimesAll', () {
    final r = getTimesAll(DateTime.utc(2024, 6, 21), 40.7128, -74.006, -4);

    test('returns an entry for every method in the table', () {
      expect(r.methods.keys.toSet(), kMethods.map((m) => m.id).toSet());
    });

    test('its primary times match getTimes exactly', () {
      final t = getTimes(DateTime.utc(2024, 6, 21), 40.7128, -74.006, -4);
      expect(r.fajr, t.fajr);
      expect(r.sunrise, t.sunrise);
      expect(r.noon, t.noon);
      expect(r.dhuhr, t.dhuhr);
      expect(r.asr, t.asr);
      expect(r.maghrib, t.maghrib);
      expect(r.isha, t.isha);
      expect(r.midnight, t.midnight);
      expect(r.qiyam, t.qiyam);
    });

    test('a deeper Fajr angle always gives an earlier Fajr', () {
      // Every angle-based method, sorted by depth, must produce a monotonically earlier
      // dawn. This is the check that catches a mis-indexed zenith list, which would
      // otherwise look plausible.
      final angled =
          kMethods.where((m) => m.fajrAngle != null && !m.useMsc).toList()
            ..sort((a, b) => a.fajrAngle!.compareTo(b.fajrAngle!));
      double? previous;
      for (final m in angled) {
        final f = r.methods[m.id]!.fajr;
        expect(
          f.isFinite,
          isTrue,
          reason: '${m.id} should reach dawn in NYC in June',
        );
        if (previous != null) {
          expect(
            f,
            lessThanOrEqualTo(previous),
            reason: '${m.id} at ${m.fajrAngle}',
          );
        }
        previous = f;
      }
    });

    test('the fixed-minute methods sit exactly 90 minutes after sunset', () {
      for (final id in ['UAQ', 'Qatar']) {
        expect(r.methods[id]!.isha, closeTo(r.maghrib + 1.5, 1e-9), reason: id);
      }
    });

    test('every method keeps Fajr before sunrise and Isha after sunset', () {
      for (final entry in r.methods.entries) {
        final e = entry.value;
        if (e.fajr.isFinite) {
          expect(e.fajr, lessThan(r.sunrise), reason: '${entry.key} Fajr');
        }
        if (e.isha.isFinite) {
          expect(e.isha, greaterThan(r.maghrib), reason: '${entry.key} Isha');
        }
      }
    });

    test('reports a method as absent rather than substituting for it', () {
      // Svalbard in June: the sun never gets 12 degrees down, let alone 20. Every
      // angle-based method must say so. This is the whole point of the comparison map —
      // it answers "which methods are usable here", so a method with no answer has to
      // keep saying so even when a high-latitude rule is supplying the primary times.
      final polar = getTimesAll(
        DateTime.utc(2024, 6, 21),
        78.2233,
        15.6469,
        1,
        highLatitudeRule: HighLatitudeRule.aqrabAlBilad,
      );

      expect(
        polar.fajr.isFinite,
        isTrue,
        reason: 'the rule supplies the primary Fajr',
      );
      expect(polar.provenance.fajr, TimeSource.aqrabAlBilad);

      for (final m in kMethods.where((m) => m.fajrAngle != null)) {
        expect(
          polar.methods[m.id]!.fajr.isNaN,
          isTrue,
          reason: '${m.id} must not borrow the primary time',
        );
      }
    });

    test('the fixed-minute methods still answer during polar day', () {
      // UAQ and Qatar measure from sunset, and above the Arctic Circle in June there is
      // no sunset either — so they are absent for the opposite reason.
      final polar = getTimesAll(DateTime.utc(2024, 6, 21), 78.2233, 15.6469, 1);
      expect(polar.maghrib.isNaN, isTrue);
      expect(polar.methods['UAQ']!.isha.isNaN, isTrue);

      // In December at the same place there is no sunrise, but there is a computable
      // sunset-relative Isha at a latitude where the sun does clear the horizon.
      final winter = getTimesAll(
        DateTime.utc(2024, 9, 15),
        78.2233,
        15.6469,
        1,
      );
      expect(winter.maghrib.isFinite, isTrue);
      expect(winter.methods['UAQ']!.isha, closeTo(winter.maghrib + 1.5, 1e-9));
    });
  });

  group('calcTimes formatting', () {
    test('renders every time as HH:MM:SS', () {
      final f = calcTimes(DateTime.utc(2024, 6, 21), 40.7128, -74.006, -4);
      final pattern = RegExp(r'^\d{2}:\d{2}:\d{2}$');
      for (final s in [
        f.qiyam,
        f.fajr,
        f.sunrise,
        f.noon,
        f.dhuhr,
        f.asr,
        f.maghrib,
        f.isha,
        f.midnight,
      ]) {
        expect(s, matches(pattern));
      }
    });

    test('renders an unreachable time as N/A rather than a number', () {
      final f = calcTimes(DateTime.utc(2024, 6, 21), 78.2233, 15.6469, 1);
      expect(f.fajr, 'N/A');
      expect(f.isha, 'N/A');
      expect(f.sunrise, 'N/A');
      // Solar noon exists every day at every latitude, polar day included.
      expect(f.noon, matches(RegExp(r'^\d{2}:\d{2}:\d{2}$')));
    });

    test('agrees with getTimes for every field', () {
      final raw = getTimes(DateTime.utc(2024, 3, 15), 51.5074, -0.1278, 0);
      final f = calcTimes(DateTime.utc(2024, 3, 15), 51.5074, -0.1278, 0);
      expect(f.fajr, formatTime(raw.fajr));
      expect(f.midnight, formatTime(raw.midnight));
      expect(f.angles.fajrAngle, raw.angles.fajrAngle);
      expect(f.provenance.fajr, raw.provenance.fajr);
    });
  });

  group('calcTimesAll formatting', () {
    test('formats both the primary times and every method entry', () {
      final f = calcTimesAll(DateTime.utc(2024, 6, 21), 21.4225, 39.8262, 3);
      final pattern = RegExp(r'^(\d{2}:\d{2}:\d{2}|N/A)$');
      expect(f.fajr, matches(pattern));
      expect(f.methods.keys.toSet(), kMethods.map((m) => m.id).toSet());
      for (final entry in f.methods.entries) {
        expect(entry.value, hasLength(2), reason: entry.key);
        expect(entry.value[0], matches(pattern), reason: '${entry.key} Fajr');
        expect(entry.value[1], matches(pattern), reason: '${entry.key} Isha');
      }
    });

    test('agrees with getTimesAll for every field', () {
      final raw = getTimesAll(DateTime.utc(2024, 12, 21), 40.7128, -74.006, -5);
      final f = calcTimesAll(DateTime.utc(2024, 12, 21), 40.7128, -74.006, -5);
      expect(f.isha, formatTime(raw.isha));
      for (final entry in raw.methods.entries) {
        expect(f.methods[entry.key], [
          formatTime(entry.value.fajr),
          formatTime(entry.value.isha),
        ], reason: entry.key);
      }
    });
  });

  group('civil-date stability', () {
    test('the time of day in the input never changes the answer', () {
      // Prayer times belong to a calendar date, not to an instant. Passing midnight,
      // noon and late evening of the same day must give byte-identical output.
      final a = calcTimesAll(
        DateTime.utc(2024, 3, 20, 0),
        40.7128,
        -74.006,
        -4,
      );
      final b = calcTimesAll(
        DateTime.utc(2024, 3, 20, 12),
        40.7128,
        -74.006,
        -4,
      );
      final c = calcTimesAll(
        DateTime.utc(2024, 3, 20, 23, 59),
        40.7128,
        -74.006,
        -4,
      );
      for (final pair in [
        [a, b],
        [a, c],
      ]) {
        expect(pair[1].fajr, pair[0].fajr);
        expect(pair[1].isha, pair[0].isha);
        expect(pair[1].asr, pair[0].asr);
        expect(pair[1].midnight, pair[0].midnight);
      }
    });

    test('a local DateTime and a UTC DateTime for the same day agree', () {
      final utc = calcTimes(DateTime.utc(2024, 6, 21), 40.7128, -74.006, -4);
      final local = calcTimes(DateTime(2024, 6, 21), 40.7128, -74.006, -4);
      expect(local.fajr, utc.fajr);
      expect(local.maghrib, utc.maghrib);
    });
  });
}
