/// PKG-10/11/12 — high-latitude rules and provenance.
///
/// Above ~48.5 degrees the sun stops reaching 18 degrees below the horizon in summer;
/// above the polar circles it stops rising or setting at all. There is then no observable
/// dawn or nightfall, so any Fajr/Isha is a juristic substitution rather than a
/// calculation. The default is to substitute NOTHING and say so.
///
/// These mirror the JS suite case for case so the two ports stay in step.
library;

import 'package:test/test.dart';
import 'package:pray_calc_dart/pray_calc_dart.dart';

void main() {
  final longyearbyen = DateTime.utc(2026, 6, 21);
  const lyLat = 78.22334, lyLng = 15.64689, lyTz = 1.0;
  final helsinkiJune = DateTime.utc(2026, 6, 21);
  const hkLat = 60.1733, hkLng = 24.941, hkTz = 3.0;

  PrayerTimes call(
    DateTime d,
    double lat,
    double lng,
    double tz,
    HighLatitudeRule rule,
  ) => getTimes(d, lat, lng, tz, highLatitudeRule: rule);

  group('PKG-10/11/12 high-latitude rules', () {
    test('default is none: nothing substituted, provenance says so', () {
      final r = getTimes(longyearbyen, lyLat, lyLng, lyTz);
      expect(r.fajr.isNaN, isTrue, reason: 'Fajr must stay absent by default');
      expect(r.isha.isNaN, isTrue, reason: 'Isha must stay absent by default');
      expect(r.provenance.fajr, TimeSource.unavailable);
      expect(r.provenance.isha, TimeSource.unavailable);
    });

    test('an observed time is reported as observed under every rule', () {
      for (final rule in HighLatitudeRule.values) {
        final r = call(DateTime.utc(2026, 3, 15), 40.7128, -74.006, -4.0, rule);
        expect(r.fajr.isFinite, isTrue);
        expect(
          r.provenance.fajr,
          TimeSource.observed,
          reason: 'rule ${rule.name}',
        );
        expect(
          r.provenance.isha,
          TimeSource.observed,
          reason: 'rule ${rule.name}',
        );
      }
    });

    test('no rule moves a time that was solved astronomically', () {
      final base = getTimes(DateTime.utc(2026, 3, 15), 40.7128, -74.006, -4.0);
      for (final rule in HighLatitudeRule.values) {
        final r = call(DateTime.utc(2026, 3, 15), 40.7128, -74.006, -4.0, rule);
        expect(
          r.fajr,
          base.fajr,
          reason: 'rule ${rule.name} moved a solved Fajr',
        );
        expect(
          r.isha,
          base.isha,
          reason: 'rule ${rule.name} moved a solved Isha',
        );
      }
    });

    for (final rule in [
      HighLatitudeRule.middleOfNight,
      HighLatitudeRule.oneSeventh,
      HighLatitudeRule.angleBased,
    ]) {
      test(
        '${rule.name} supplies a time where a real sunset exists (Helsinki June)',
        () {
          final r = call(helsinkiJune, hkLat, hkLng, hkTz, rule);
          expect(
            r.isha.isFinite,
            isTrue,
            reason: '${rule.name} should supply Isha',
          );
          expect(r.provenance.isha, TimeSource.values.byName(rule.name));
        },
      );

      test('${rule.name} cannot help without a sunset (Longyearbyen June)', () {
        final r = call(longyearbyen, lyLat, lyLng, lyTz, rule);
        expect(r.fajr.isNaN, isTrue);
        expect(r.isha.isNaN, isTrue);
        expect(r.provenance.fajr, TimeSource.unavailable);
      });
    }

    test('aqrabAlBilad supplies both times and matches the 45th parallel', () {
      final r = call(
        longyearbyen,
        lyLat,
        lyLng,
        lyTz,
        HighLatitudeRule.aqrabAlBilad,
      );
      expect(r.fajr.isFinite, isTrue);
      expect(r.isha.isFinite, isTrue);
      expect(r.provenance.fajr, TimeSource.aqrabAlBilad);
      final at45 = getTimes(longyearbyen, 45, lyLng, lyTz);
      expect((r.fajr - at45.fajr).abs() < 1e-9, isTrue);
      expect((r.isha - at45.isha).abs() < 1e-9, isTrue);
    });

    test('aqrabAlBilad borrows from the matching hemisphere', () {
      final mcmurdo = DateTime.utc(2026, 6, 21);
      final r = call(
        mcmurdo,
        -77.8419,
        166.6863,
        13.0,
        HighLatitudeRule.aqrabAlBilad,
      );
      final south = getTimes(mcmurdo, -45, 166.6863, 13.0);
      expect(r.fajr.isFinite, isTrue);
      expect(
        (r.fajr - south.fajr).abs() < 1e-9,
        isTrue,
        reason: 'must borrow from 45 SOUTH to keep the season',
      );
    });

    test('aqrabAlAyyam supplies both times during polar day', () {
      final r = call(
        longyearbyen,
        lyLat,
        lyLng,
        lyTz,
        HighLatitudeRule.aqrabAlAyyam,
      );
      expect(r.fajr.isFinite, isTrue);
      expect(r.isha.isFinite, isTrue);
      expect(r.provenance.fajr, TimeSource.aqrabAlAyyam);
      expect(r.fajr >= 0 && r.fajr < 24, isTrue);
      expect(r.isha >= 0 && r.isha < 24, isTrue);
    });

    test('both nearest-substitution rules cover every day of the year', () {
      for (final rule in [
        HighLatitudeRule.aqrabAlBilad,
        HighLatitudeRule.aqrabAlAyyam,
      ]) {
        var gaps = 0;
        for (var i = 0; i < 365; i++) {
          final d = DateTime.utc(2026, 1, 1).add(Duration(days: i));
          final r = getTimes(d, lyLat, lyLng, lyTz, highLatitudeRule: rule);
          if (!r.fajr.isFinite || !r.isha.isFinite) gaps++;
        }
        expect(
          gaps,
          0,
          reason: '${rule.name} left $gaps days without Fajr/Isha',
        );
      }
    });
  });
}
