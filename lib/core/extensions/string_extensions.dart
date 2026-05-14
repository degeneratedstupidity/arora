/// Extension methods on [String] for common UI transforms.
library;

extension StringHelpers on String {
  /// Capitalises the first letter of the string.
  /// ```dart
  /// 'hello world'.capitalised // → 'Hello world'
  /// ```
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Returns `true` if the string is not empty after trimming whitespace.
  bool get isNotBlank => trim().isNotEmpty;

  /// Truncates the string to [maxLength] and appends `…` if needed.
  /// ```dart
  /// 'A very long title'.truncate(10) // → 'A very lon…'
  /// ```
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}…';
}
