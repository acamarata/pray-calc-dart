# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed

- Replaced bundled SPA implementation with the `nrel_spa` package dependency
- Removed `SpaResult` and `SpaAnglesResult` from local types (now re-exported from `nrel_spa`)

## [1.0.0] - 2026-03-08

### Added

- `getTimes()` computes all prayer times using the PrayCalc Dynamic Method
- `getAngles()` returns adaptive Fajr/Isha twilight depression angles
- `getSpa()` full NREL Solar Position Algorithm (SPA) implementation
- `solarEphemeris()` low-precision Jean Meeus Ch. 25 ephemeris
- `getAsr()` computes Asr time for Shafi'i or Hanafi conventions
- `getQiyam()` computes start of the last third of the night
- `getMscFajr()` and `getMscIsha()` MCW seasonal offsets
- `formatTime()` converts fractional hours to HH:MM:SS strings
- `minutesToDepression()` converts time offsets to depression angles
- Full type definitions: PrayerTimes, FormattedPrayerTimes, TwilightAngles, SpaResult, SolarEphemeris
- Comprehensive test suite validated against pray-calc TypeScript v2.0.0
