/// Extension methods on [Duration] for human-friendly formatting.
library;

extension DurationFormatting on Duration {
  /// Formats the duration as `MM:SS` (e.g., `3:47`, `12:04`).
  ///
  /// Hours are omitted unless the duration is >= 1 hour.
  /// ```dart
  /// Duration(minutes: 3, seconds: 47).toMMSS() // → "3:47"
  /// Duration(hours: 1, minutes: 2).toMMSS()    // → "1:02:00"
  /// ```
  String toMMSS() {
    final h = inHours;
    final m = inMinutes.remainder(60);
    final s = inSeconds.remainder(60);

    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');

    if (h > 0) return '$h:$mm:$ss';
    return '$m:$ss';
  }

  /// Returns `true` if this duration is zero.
  bool get isZero => inMilliseconds == 0;
}
