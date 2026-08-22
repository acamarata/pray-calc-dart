/// Islamic midnight calculation.
///
/// The midpoint of the night, commonly used as the endpoint of the Isha prayer window.
/// The standard definition spans Maghrib to Fajr; the astronomical variant spans Maghrib
/// to Sunrise. Which endpoint to pass is the caller's choice.
library;

/// Compute the midpoint of the night.
///
/// [maghribTime] is Maghrib (sunset) in fractional hours; [endTime] is Fajr or Sunrise in
/// fractional hours, understood as the following morning.
///
/// Returns the midpoint as fractional hours, wrapped into [0, 24).
double getMidnight(double maghribTime, double endTime) {
  if (!maghribTime.isFinite || !endTime.isFinite) return double.nan;

  // When endTime is numerically earlier than Maghrib (e.g. 5.5 against 20.0), the endpoint
  // is on the NEXT day: add 24 to measure the real span rather than a negative one.
  final adjusted = endTime < maghribTime ? endTime + 24 : endTime;

  final mid = maghribTime + (adjusted - maghribTime) / 2;

  return mid >= 24 ? mid - 24 : mid;
}
