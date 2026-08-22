/// Shared constants for pray_calc_dart.
///
/// Values mirror the JavaScript `pray-calc` package exactly so the two ports produce
/// identical output for identical input.
library;

/// Minutes added to solar noon to obtain Dhuhr time.
///
/// Standard practice adds a small buffer after geometric solar transit to ensure the sun
/// has clearly passed the meridian before Dhuhr begins. The 2.5-minute convention is
/// widely used across Islamic timekeeping authorities and accounts for the sun's angular
/// diameter (about 0.5 degrees) plus a small safety margin.
const double kDhuhrOffsetMinutes = 2.5;

/// Minimum allowed dynamic twilight depression angle, in degrees.
///
/// At very high latitudes in summer the MCW base angle can drop below physically
/// meaningful values. 10 degrees is the lower clamp — below this the sky is too bright for
/// any twilight definition.
///
/// Note that above roughly 70 degrees latitude the computed angle sits at this floor, which
/// is outside the latitude span the Moonsighting Committee data was fitted to. Treat
/// results there as the edge of the model's validated range.
const double kAngleMin = 10;

/// Maximum allowed dynamic twilight depression angle, in degrees.
///
/// 22 degrees is the upper clamp. Values above about 20 correspond to deep astronomical
/// twilight where the sky is indistinguishable from full night. No standard method exceeds
/// 20 degrees for Fajr.
const double kAngleMax = 22;
