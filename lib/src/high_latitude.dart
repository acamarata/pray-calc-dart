/// High-latitude rules for Fajr and Isha.
///
/// Above roughly 48.5 degrees the sun stops reaching 18 degrees below the horizon in
/// summer; above the polar circles it stops rising or setting altogether for weeks. In
/// those conditions there is no observable dawn or nightfall, so no calculation can
/// produce Fajr or Isha — every answer is a juristic substitution rather than an
/// astronomical result.
///
/// This library implements the substitutions. It never picks one on its own: the default
/// is [HighLatitudeRule.none], which reports the times as absent and leaves the choice to
/// the caller. Every substituted time is tagged with the rule that produced it (see
/// [TimeProvenance]) so a caller can always tell a computed time from a supplied one.
///
/// Two families, with different reach:
///
/// - **Night proportions** ([HighLatitudeRule.middleOfNight],
///   [HighLatitudeRule.oneSeventh], [HighLatitudeRule.angleBased]) divide the night
///   between sunset and sunrise. They need a real sunset and sunrise to measure, so they
///   cover "no true darkness" latitudes such as Helsinki in June and do nothing at all
///   for Svalbard in July, where neither event occurs.
/// - **Nearest substitutions** ([HighLatitudeRule.aqrabAlBilad],
///   [HighLatitudeRule.aqrabAlAyyam]) borrow from a place or a date where the sign is
///   observable. These are the only rules that cover the polar circles.
library;

/// Rule used to supply Fajr and Isha when no observable time exists.
enum HighLatitudeRule {
  /// Report unreachable times as absent. The default: substitute nothing.
  none,

  /// Split the night in half: Fajr at midnight, Isha at midnight.
  middleOfNight,

  /// One seventh of the night: Isha after the first seventh, Fajr before the last.
  oneSeventh,

  /// Portion of the night proportional to the method's depression angle.
  angleBased,

  /// Nearest latitude (Aqrab al-Bilad): recompute at the 45th parallel.
  aqrabAlBilad,

  /// Nearest day (Aqrab al-Ayyam): borrow the closest date with an observable sign.
  aqrabAlAyyam,
}

/// Where a given time came from.
enum TimeSource {
  /// Solved from the sun's actual position on this date at this location.
  observed,
  middleOfNight,
  oneSeventh,
  angleBased,
  aqrabAlBilad,
  aqrabAlAyyam,

  /// No observable time and no rule able to supply one.
  unavailable,
}

/// Origin of each substitutable time in a result.
class TimeProvenance {
  final TimeSource fajr;
  final TimeSource isha;

  const TimeProvenance({required this.fajr, required this.isha});

  @override
  String toString() => 'TimeProvenance(fajr: ${fajr.name}, isha: ${isha.name})';
}

/// Latitude the Aqrab al-Bilad rule falls back to, in degrees.
const double kAqrabAlBiladLatitude = 45;

/// How far Aqrab al-Ayyam will search for a usable date, in days each way.
const int _kAqrabAlAyyamMaxSearchDays = 200;

/// Fajr, Isha and Noon for one resolved day. Returned by a [DayResolver].
class ResolvedDay {
  final double fajr;
  final double isha;
  final double noon;

  const ResolvedDay({
    required this.fajr,
    required this.isha,
    required this.noon,
  });
}

/// Recomputes a day at arbitrary coordinates/date. Supplied by the caller so this
/// library stays free of a circular import back into getTimes.
typedef DayResolver =
    ResolvedDay Function(DateTime date, double lat, double lng);

/// Inputs the rules need beyond the times themselves.
class HighLatitudeContext {
  final HighLatitudeRule rule;
  final DateTime date;
  final double lat;
  final double lng;

  /// Depression angles used for this calculation, for the angleBased rule.
  final double fajrAngle;
  final double ishaAngle;
  final DayResolver resolveDay;

  const HighLatitudeContext({
    required this.rule,
    required this.date,
    required this.lat,
    required this.lng,
    required this.fajrAngle,
    required this.ishaAngle,
    required this.resolveDay,
  });
}

/// Resolved Fajr and Isha plus the origin of each.
class HighLatitudeResult {
  final double fajr;
  final double isha;
  final TimeProvenance provenance;

  const HighLatitudeResult({
    required this.fajr,
    required this.isha,
    required this.provenance,
  });
}

bool _isUsable(double value) => value.isFinite;

/// Times are fractional hours from midnight of the requested civil date, and are
/// deliberately NOT wrapped into [0, 24).
///
/// The observed path already works this way: at Helsinki in mid-May `getTimes` returns an
/// Isha of 24.163, meaning 00:09 the next morning. Wrapping a substituted time into the
/// same day instead put Isha *before* Fajr, which is exactly the "times are out of order"
/// symptom that makes a polar timetable look broken. Leaving it un-wrapped keeps
/// Fajr < Isha true by construction and leaves the day-rollover to the caller.

/// Fraction of the night to offset from sunset/sunrise for the night-proportion rules.
/// Returns NaN for rules that are not night proportions.
double _nightPortion(HighLatitudeRule rule, double angleDeg) {
  switch (rule) {
    case HighLatitudeRule.angleBased:
      return angleDeg / 60;
    case HighLatitudeRule.oneSeventh:
      return 1 / 7;
    case HighLatitudeRule.middleOfNight:
      return 1 / 2;
    default:
      return double.nan;
  }
}

/// Night-proportion substitution. Requires a real sunset and sunrise to measure against.
double _applyNightPortion(
  HighLatitudeRule rule,
  double sunrise,
  double maghrib,
  double angleDeg, {
  required bool isFajr,
}) {
  if (!_isUsable(sunrise) || !_isUsable(maghrib)) return double.nan;
  final portion = _nightPortion(rule, angleDeg);
  if (!_isUsable(portion)) return double.nan;
  // At extreme latitudes sunset can land just after local midnight and come back as a
  // small value numerically below sunrise. Unwrap onto one continuous axis first.
  final maghribUnwrapped = maghrib < sunrise ? maghrib + 24 : maghrib;
  final nightLength = 24 - (maghribUnwrapped - sunrise);
  final offset = portion * nightLength;
  return isFajr ? sunrise - offset : maghribUnwrapped + offset;
}

/// Aqrab al-Bilad — nearest location. Recompute the same date at the 45th parallel,
/// keeping longitude (and therefore the local solar day) intact.
///
/// The 45-degree convention is the one most North American and European institutions
/// use. The sign of the observer's own latitude is preserved so a southern-hemisphere
/// observer borrows from 45 degrees south, matching their season.
ResolvedDay _applyAqrabAlBilad(HighLatitudeContext ctx) {
  final sign = ctx.lat < 0 ? -1.0 : 1.0;
  final fallbackLat =
      sign *
      (ctx.lat.abs() < kAqrabAlBiladLatitude
          ? ctx.lat.abs()
          : kAqrabAlBiladLatitude);
  return ctx.resolveDay(ctx.date, fallbackLat, ctx.lng);
}

/// Aqrab al-Ayyam — nearest day. Walk outward from the requested date, one day at a time
/// in both directions, until a date at this same location yields an observable time.
///
/// The borrowed time is carried across as an offset from solar noon rather than as a
/// clock reading. Solar noon exists every day at every latitude, so the offset transfers
/// cleanly and stays anchored to the observer's own solar day.
ResolvedDay _applyAqrabAlAyyam(HighLatitudeContext ctx) {
  final today = ctx.resolveDay(ctx.date, ctx.lat, ctx.lng);
  var fajr = today.fajr;
  var isha = today.isha;
  if (_isUsable(fajr) && _isUsable(isha)) {
    return ResolvedDay(fajr: fajr, isha: isha, noon: today.noon);
  }

  final baseNoon = today.noon;
  if (!_isUsable(baseNoon)) {
    return const ResolvedDay(
      fajr: double.nan,
      isha: double.nan,
      noon: double.nan,
    );
  }

  for (var delta = 1; delta <= _kAqrabAlAyyamMaxSearchDays; delta++) {
    for (final direction in const [-1, 1]) {
      if (_isUsable(fajr) && _isUsable(isha)) break;
      final probeDate = ctx.date.add(Duration(days: direction * delta));
      final probe = ctx.resolveDay(probeDate, ctx.lat, ctx.lng);
      if (!_isUsable(probe.noon)) continue;
      if (!_isUsable(fajr) && _isUsable(probe.fajr)) {
        fajr = baseNoon + (probe.fajr - probe.noon);
      }
      if (!_isUsable(isha) && _isUsable(probe.isha)) {
        isha = baseNoon + (probe.isha - probe.noon);
      }
    }
    if (_isUsable(fajr) && _isUsable(isha)) break;
  }

  // Un-wrapped by design: probe.fajr < probe.noon < probe.isha, so carrying both across as
  // offsets from this day's noon preserves fajr < isha even when isha lands past midnight.
  return ResolvedDay(fajr: fajr, isha: isha, noon: baseNoon);
}

/// Supply Fajr and Isha where the sun provides no observable time.
///
/// Times that were solved astronomically are passed through untouched and reported as
/// [TimeSource.observed]. Only genuinely absent values are substituted, and only by the
/// rule the caller asked for.
HighLatitudeResult applyHighLatitudeRule(
  HighLatitudeContext ctx,
  double fajr,
  double isha,
  double sunrise,
  double maghrib,
) {
  final fajrObserved = _isUsable(fajr);
  final ishaObserved = _isUsable(isha);

  if (fajrObserved && ishaObserved) {
    return HighLatitudeResult(
      fajr: fajr,
      isha: isha,
      provenance: const TimeProvenance(
        fajr: TimeSource.observed,
        isha: TimeSource.observed,
      ),
    );
  }

  if (ctx.rule == HighLatitudeRule.none) {
    return HighLatitudeResult(
      fajr: fajr,
      isha: isha,
      provenance: TimeProvenance(
        fajr: fajrObserved ? TimeSource.observed : TimeSource.unavailable,
        isha: ishaObserved ? TimeSource.observed : TimeSource.unavailable,
      ),
    );
  }

  double suppliedFajr = double.nan;
  double suppliedIsha = double.nan;

  switch (ctx.rule) {
    case HighLatitudeRule.aqrabAlBilad:
      final r = _applyAqrabAlBilad(ctx);
      suppliedFajr = r.fajr;
      suppliedIsha = r.isha;
    case HighLatitudeRule.aqrabAlAyyam:
      final r = _applyAqrabAlAyyam(ctx);
      suppliedFajr = r.fajr;
      suppliedIsha = r.isha;
    default:
      suppliedFajr = _applyNightPortion(
        ctx.rule,
        sunrise,
        maghrib,
        ctx.fajrAngle,
        isFajr: true,
      );
      suppliedIsha = _applyNightPortion(
        ctx.rule,
        sunrise,
        maghrib,
        ctx.ishaAngle,
        isFajr: false,
      );
  }

  final resolvedFajr = fajrObserved ? fajr : suppliedFajr;
  final resolvedIsha = ishaObserved ? isha : suppliedIsha;

  TimeSource sourceFor(bool observed, double resolved) {
    if (observed) return TimeSource.observed;
    if (!_isUsable(resolved)) return TimeSource.unavailable;
    return TimeSource.values.byName(ctx.rule.name);
  }

  return HighLatitudeResult(
    fajr: resolvedFajr,
    isha: resolvedIsha,
    provenance: TimeProvenance(
      fajr: sourceFor(fajrObserved, resolvedFajr),
      isha: sourceFor(ishaObserved, resolvedIsha),
    ),
  );
}
