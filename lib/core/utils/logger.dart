/// Structured logger for Arora.
///
/// Wraps Dart's built-in `print` behind a structured API that:
/// - Is a no-op in release mode (zero overhead in production).
/// - Prefixes messages with severity level and source tag.
/// - Can be replaced with a full logging framework (e.g., `logger` package)
///   by changing only this file.
///
/// ## Usage
/// ```dart
/// // Import once per file, create a tagged logger:
/// final _log = AroraLogger('MyFeature');
///
/// _log.debug('Widget rebuilt');
/// _log.info('Playback started: ${song.title}');
/// _log.warn('Stream URL expired, refreshing');
/// _log.error('Failed to load lyrics', error: e, stackTrace: st);
/// ```
library;

import 'package:flutter/foundation.dart' show kDebugMode;

/// A lightweight, tagged logger.
///
/// Create one instance per class/file for contextual log output:
/// ```dart
/// final _log = AroraLogger('AudioPlayerService');
/// ```
final class AroraLogger {
  /// Creates a logger tagged with [tag] (typically the class name).
  const AroraLogger(this.tag);

  /// Identifies the source of this log message.
  final String tag;

  // ── Log levels ──────────────────────────────────────────────────────────

  /// Verbose diagnostic information. Only visible in debug mode.
  void debug(String message) => _log('DEBUG', message);

  /// Informational messages about normal app flow.
  void info(String message) => _log('INFO ', message);

  /// Potentially harmful situations that don't halt execution.
  void warn(String message, {Object? error}) =>
      _log('WARN ', '$message${error != null ? ' | $error' : ''}');

  /// Errors that affect functionality. Includes stack trace when available.
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('ERROR', '$message${error != null ? ' | $error' : ''}');
    if (stackTrace != null && kDebugMode) {
      // ignore: avoid_print
      print(stackTrace);
    }
  }

  // ── Internal ────────────────────────────────────────────────────────────

  void _log(String level, String message) {
    if (!kDebugMode) return; // Silent in release builds
    final time = DateTime.now().toIso8601String().substring(11, 23);
    // ignore: avoid_print
    print('[$time][$level][$tag] $message');
  }
}
