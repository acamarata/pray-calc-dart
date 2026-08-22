/// Cross-language parity against the JavaScript `pray-calc` package.
///
/// The two ports are transcriptions of the same algorithm and are expected to agree
/// exactly, not approximately. This suite pins that: `test/fixtures/cross_language_golden.json`
/// holds the formatted output of the JS package for 282 combinations of location, date,
/// Asr convention and high-latitude rule, and every one is asserted here as an exact
/// string match.
///
/// Exact rather than tolerant on purpose. A tolerance hides precisely the class of bug
/// this file exists to catch — a divergence that starts at a fraction of a second and
/// grows, or one that only shows up at a single latitude. If a real algorithm change lands
/// in both ports, regenerate the fixture from the JS side rather than loosening the
/// comparison.
///
/// The fixture is produced by the JavaScript package, which is the reference
/// implementation here, so regeneration happens on that side: see
/// `tool/generate-parity-fixture.mjs` in the `pray-calc` repository, and copy its output
/// over `test/fixtures/cross_language_golden.json`.
library;

import 'dart:convert';
import 'dart:io';

import 'package:pray_calc_dart/pray_calc_dart.dart';
import 'package:test/test.dart';

/// The rule names as the JSON fixture spells them.
HighLatitudeRule _ruleFrom(String name) =>
    HighLatitudeRule.values.firstWhere((r) => r.name == name);

void main() {
  final file = File('test/fixtures/cross_language_golden.json');
  final vectors = (jsonDecode(file.readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();

  test('fixture is present and non-trivial', () {
    expect(vectors.length, greaterThan(250));
  });

  group('cross-language parity with the JavaScript pray-calc package', () {
    for (final v in vectors) {
      final name = v['name'] as String;
      final date = v['d'] as String;
      final hanafi = v['hanafi'] as bool;
      final rule = v['rule'] as String;
      final label =
          '$name $date${hanafi ? ' hanafi' : ''}${rule == 'none' ? '' : ' $rule'}';

      test(label, () {
        final parts = date.split('-').map(int.parse).toList();
        final r = calcTimesAll(
          DateTime.utc(parts[0], parts[1], parts[2]),
          (v['lat'] as num).toDouble(),
          (v['lng'] as num).toDouble(),
          (v['tz'] as num).toDouble(),
          hanafi: hanafi,
          highLatitudeRule: _ruleFrom(rule),
        );

        final expectedTimes = (v['t'] as List).cast<String>();
        final actualTimes = [
          r.qiyam,
          r.fajr,
          r.sunrise,
          r.noon,
          r.dhuhr,
          r.asr,
          r.maghrib,
          r.isha,
          r.midnight,
        ];
        const labels = [
          'Qiyam',
          'Fajr',
          'Sunrise',
          'Noon',
          'Dhuhr',
          'Asr',
          'Maghrib',
          'Isha',
          'Midnight',
        ];
        for (var i = 0; i < labels.length; i++) {
          expect(actualTimes[i], expectedTimes[i], reason: '${labels[i]} at $label');
        }

        final expectedAngles = (v['a'] as List).cast<num>();
        expect(
          r.angles.fajrAngle,
          closeTo(expectedAngles[0].toDouble(), 1e-9),
          reason: 'fajrAngle at $label',
        );
        expect(
          r.angles.ishaAngle,
          closeTo(expectedAngles[1].toDouble(), 1e-9),
          reason: 'ishaAngle at $label',
        );

        final expectedProv = (v['p'] as List).cast<String>();
        expect(r.provenance.fajr.name, expectedProv[0], reason: 'Fajr source at $label');
        expect(r.provenance.isha.name, expectedProv[1], reason: 'Isha source at $label');

        final expectedMethods = (v['M'] as Map).cast<String, dynamic>();
        expect(
          r.methods.keys.toSet(),
          expectedMethods.keys.toSet(),
          reason: 'method set at $label',
        );
        for (final entry in expectedMethods.entries) {
          final pair = (entry.value as List).cast<String>();
          expect(r.methods[entry.key], pair, reason: '${entry.key} at $label');
        }
      });
    }
  });
}
