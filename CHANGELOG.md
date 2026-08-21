## 1.1.1

### Fixed
- **Substituted `fajr`/`isha` are no longer wrapped into [0, 24), which could put Isha before Fajr.** The observed path already returns a post-midnight Isha as e.g. `24.163` (00:09 the next morning) and never wraps; the high-latitude substitution paths did, so a supplied Isha landed at the start of the same day and sorted ahead of Fajr. At Longyearbyen under `aqrabAlAyyam` that affected 158 days a year, and every night-proportion rule was affected too. Substituted times now follow the same convention as computed ones, so `fajr < isha` holds by construction.

## 1.1.0

### Added
- **High-latitude rules for Fajr and Isha**, opt-in via the `highLatitudeRule` named
  argument on `getTimes`. Six options: `none` (default), `middleOfNight`, `oneSeventh`,
  `angleBased`, `aqrabAlBilad` (nearest latitude, the 45th parallel) and `aqrabAlAyyam`
  (nearest date with an observable sign). The default substitutes nothing: past the
  geometric limit every answer is a juristic position rather than a calculation, and a
  library that picks one silently is issuing a ruling on the caller's behalf.
- **`provenance` on every result**, naming the origin of `fajr` and `isha` as `observed`,
  the rule that supplied it, or `unavailable`.

### Fixed
- Requires `nrel_spa` >= 1.1.0, which stops the NREL `-99999` sentinel from reaching
  callers. With earlier versions an unreachable time arrived as a finite number and passed
  every `isFinite` guard.
- `dhuhr` and `asr` are now available every day at every latitude, following the
  `solarNoon` recovery in nrel_spa 1.1.0. At Longyearbyen on 2026-06-21 the package
  previously returned nothing at all; it now returns Dhuhr 12:01:43 and Asr 18:07:51 with
  Fajr, Sunrise, Maghrib and Isha correctly absent.

### Notes
- The three night-proportion rules divide the span between sunset and sunrise, so inside
  the polar circles they have nothing to measure and correctly decline. Only
  `aqrabAlBilad` and `aqrabAlAyyam` cover those latitudes.
- Output verified byte-identical to the JS `pray-calc` package to 9 decimal places.

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
