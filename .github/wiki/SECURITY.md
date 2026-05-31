# Security

## Scope

`pray_calc_dart` is a pure-math library with no network access, no file I/O, and no external dependencies beyond `nrel_spa`. The attack surface is limited to the mathematical functions themselves.

The main concern is input validation: functions accept latitude (-90 to 90), longitude (-180 to 180), and UTC offset. Out-of-range values produce undefined behavior — clamp inputs to valid ranges before passing untrusted data.

## Reporting a Vulnerability

If you discover a security issue (for example, a case where malformed input causes unexpected behavior or crashes), please report it privately before filing a public issue.

**Contact:** alisalaah@gmail.com

Include:

1. A description of the vulnerability
2. Steps to reproduce it
3. The version of `pray_calc_dart` where you observed the issue
4. Any suggested fix if you have one

You can expect an acknowledgment within 48 hours and a resolution or status update within 7 days.

## Known Limitations

- Prayer times are computed using the NREL Solar Position Algorithm. Accuracy is approximately one second relative to the reference implementation. Results near polar latitudes (above 65 degrees N/S) should be treated as estimates.
- The MCW seasonal model uses empirical piecewise-linear functions. Accuracy at extreme latitudes degrades gracefully rather than producing errors, but times may differ from local observation.
- Time zone handling is the caller's responsibility. The library accepts a UTC offset in hours and returns fractional hours in that offset. DST adjustments must be applied by the caller.
