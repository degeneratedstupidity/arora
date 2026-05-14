/// Audio quality levels for stream URL requests.
///
/// Providers receive this enum and should gracefully degrade:
/// `lossless` → `high` → `medium` → `low`
/// if the requested quality is unavailable.
library;

/// The desired audio bitrate / codec quality tier.
enum AudioQuality {
  /// Low quality — ~96 kbps. Minimal data usage.
  low,

  /// Medium quality — ~128 kbps. Balanced quality / data.
  medium,

  /// High quality — ~256–320 kbps. Recommended default.
  high,

  /// Lossless / highest available bitrate (e.g., Opus 160 kbps on YouTube).
  /// Falls back to [high] when not available.
  lossless;

  /// Human-readable label for display in Settings.
  String get label => switch (this) {
        AudioQuality.low => 'Low (~96 kbps)',
        AudioQuality.medium => 'Medium (~128 kbps)',
        AudioQuality.high => 'High (~256 kbps)',
        AudioQuality.lossless => 'Best Available',
      };
}
