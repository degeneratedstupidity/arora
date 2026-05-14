import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'song.freezed.dart';
part 'song.g.dart';

/// The core domain entity representing a single playable track.
///
/// [Song] is an immutable value object — you never mutate it in place.
/// Instead, use `song.copyWith(...)` to derive a new instance.
///
/// ## Identity
/// Songs from remote providers use a provider-specific [id].
/// Downloaded songs that exist locally retain the same [id].
///
/// ## Music Video support
/// When [hasVideo] is `true`, the Now Playing screen shows an
/// `[Audio] [Video]` mode toggle. The [videoId] field holds the
/// YouTube video ID (or equivalent) used to resolve the video stream.
@freezed
@HiveType(typeId: 0, adapterName: 'SongAdapter')
abstract class Song with _$Song {
  const factory Song({
    /// Unique identifier (provider-specific, e.g., YouTube video ID).
    @HiveField(0) required String id,

    /// Track title as returned by the provider.
    @HiveField(1) required String title,

    /// Primary artist name (display string).
    @HiveField(2) required String artistName,

    /// Album or single name. Null if not available.
    @HiveField(3) String? albumName,

    /// URL to the best-quality thumbnail / album art image.
    @HiveField(4) String? thumbnailUrl,

    /// Track duration in milliseconds. Null if unknown before streaming.
    @HiveField(5) int? durationMs,

    // ── Music Video ──────────────────────────────────────────────────────

    /// Whether this track has an associated music video.
    ///
    /// When true, the Now Playing screen shows an Audio/Video toggle.
    @HiveField(6) @Default(false) bool hasVideo,

    /// The video ID used to resolve the music video stream URL.
    ///
    /// For the YouTube provider this is the same as [id].
    /// For other providers this may differ or be null when [hasVideo] is false.
    @HiveField(7) String? videoId,

    // ── Offline / Download ───────────────────────────────────────────────

    /// Whether this track has been downloaded for offline playback.
    @HiveField(8) @Default(false) bool isDownloaded,

    /// Absolute path to the locally cached audio file.
    /// Null when the track has not been downloaded.
    @HiveField(9) String? localFilePath,

    // ── Metadata ────────────────────────────────────────────────────────

    /// ISO 8601 date string of when the track was released, if known.
    @HiveField(10) String? releaseDate,

    /// Number of times this track has been played in the current session.
    @HiveField(11) @Default(0) int playCount,
  }) = _Song;
}
