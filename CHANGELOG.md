# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/).

## 1.0.1 - 2026-06-13

### Fixed

- Prayer times are now host-timezone-independent. `getTimes` normalizes the
  caller's `date` to a stable UTC-noon reference (`DateTime.utc(y, m, d, 12)`)
  before passing it to `getSpa` and all astronomical calculations. Previously,
  a local `DateTime(2024, 3, 15)` in a UTC+12 zone would reach `getSpa` as
  UTC March 14, shifting all times by one civil day.

## [1.0.0] - 2026-05-25

### Added

- Initial public release.
- `getTimes` — calculates Fajr, Dhuhr, Asr, Maghrib, Isha, midnight, and Qiyam times for any date and location.
- MCW seasonal model for Fajr and Isha twilight angles.
- Dynamic Prayer Calculation (DPC) algorithm with ML-calibrated depression angles.
- `PrayerConfig` — configurable madhab (Hanafi/standard Asr), calculation method, and UTC offset.
- Pure Dart implementation. Zero runtime dependencies beyond `nrel_spa`.
- Depends on `nrel_spa ^1.0.0` for NREL Solar Position Algorithm.
- Dart SDK `^3.7.0` compatibility.
- 24 unit tests covering all 7 prayer outputs across known locations and dates.
