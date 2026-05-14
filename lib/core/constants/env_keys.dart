/// String keys for values loaded from the `.env` file via [flutter_dotenv].
///
/// ## Why this file exists
/// Using raw string literals like `dotenv.env['MY_KEY']` scattered across the
/// codebase is error-prone (typos cause silent null reads). Instead, every
/// consumer uses the typed constants defined here.
///
/// ## Usage
/// ```dart
/// import 'package:flutter_dotenv/flutter_dotenv.dart';
/// import 'package:arora/core/constants/env_keys.dart';
///
/// final apiKey = dotenv.env[EnvKeys.fallbackApiKey]; // type-safe access
/// ```
library;

/// @nodoc
abstract final class EnvKeys {
  /// Base URL for the optional fallback music API (Phase 2+).
  static const String fallbackApiBaseUrl = 'FALLBACK_API_BASE_URL';

  /// API key for the optional fallback music API (Phase 2+).
  static const String fallbackApiKey = 'FALLBACK_API_KEY';

  /// API key for a dedicated lyrics provider (Phase 2+).
  static const String lyricsApiKey = 'LYRICS_API_KEY';

  /// Sentry DSN for production crash reporting (optional).
  static const String sentryDsn = 'SENTRY_DSN';
}
