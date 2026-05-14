/// App-wide constants for Arora.
///
/// All magic numbers, timeouts, and configuration values live here.
/// This makes tuning behaviour (e.g., changing page size) a single-place change.
library;

abstract final class AppConstants {
  // ── Pagination ─────────────────────────────────────────────────────────
  /// Default number of results returned per search/discovery request.
  static const int defaultPageSize = 20;

  /// Maximum number of results that can be requested in a single page.
  static const int maxPageSize = 50;

  // ── Smart Shuffle Engine ───────────────────────────────────────────────
  /// When the playback queue has this many songs remaining, the
  /// [SmartShuffleEngine] triggers a recommendation fetch from the provider.
  static const int shuffleRefillThreshold = 3;

  /// Number of recommendation tracks fetched per refill cycle.
  static const int recommendationBatchSize = 10;

  // ── Audio ──────────────────────────────────────────────────────────────
  /// Duration in milliseconds that the skip-back button rewinds.
  static const int seekBackwardMs = 10000; // 10 seconds

  /// Duration in milliseconds that the skip-forward button fast-forwards.
  static const int seekForwardMs = 30000; // 30 seconds

  // ── Downloads ─────────────────────────────────────────────────────────
  /// Subdirectory name within path_provider's app documents directory
  /// where downloaded audio files are stored.
  static const String downloadsDirName = 'arora_downloads';

  // ── UI Transitions ─────────────────────────────────────────────────────
  /// Standard duration for page route transitions.
  static const Duration routeTransitionDuration = Duration(milliseconds: 300);

  /// Duration for micro-animation hover / tap effects.
  static const Duration microAnimationDuration = Duration(milliseconds: 150);

  // ── Cache ──────────────────────────────────────────────────────────────
  /// Maximum age for cached stream URLs before they are considered stale.
  /// YouTube stream URLs typically expire after 6 hours.
  static const Duration streamUrlTtl = Duration(hours: 5);
}
