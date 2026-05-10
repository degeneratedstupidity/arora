/// Video quality levels for music video stream requests.
library;

/// The desired video resolution for music video playback.
enum VideoQuality {
  /// 360p — lowest bandwidth. Good for mobile data.
  p360,

  /// 720p — HD. Recommended default for WiFi.
  p720,

  /// 1080p — Full HD. Requires good connection.
  p1080;

  /// Human-readable label for display in Settings / quality picker.
  String get label => switch (this) {
        VideoQuality.p360 => '360p',
        VideoQuality.p720 => '720p HD',
        VideoQuality.p1080 => '1080p Full HD',
      };
}
