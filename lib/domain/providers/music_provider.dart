import 'package:arora/domain/entities/album.dart';
import 'package:arora/domain/entities/lyrics.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/enums/audio_quality.dart';
import 'package:arora/domain/enums/video_quality.dart';

/// {@template music_provider}
/// Abstract contract that every music API integration MUST fulfill.
///
/// ## Architecture (Repository Pattern)
/// Arora's entire UI and business logic layer depends **only** on this
/// interface, never on a concrete provider. This means:
///
/// - Swapping APIs (YouTube → Spotify → Deezer) requires zero UI changes.
/// - Unit-testing any feature is done against the [MockMusicProvider] with
///   no network access.
/// - Contributors can add a new provider without understanding the app internals.
///
/// ## How to add a new provider
/// 1. Create `lib/infrastructure/<name>/<Name>MusicProvider.dart`
/// 2. `class YourProvider extends MusicProvider { ... }`
/// 3. Implement **every** method declared below.
/// 4. Register it in `lib/app.dart` via the Riverpod `musicProviderProvider`.
///
/// ## Current implementations
/// | Class | Location | Status |
/// |---|---|---|
/// | [MockMusicProvider] | `lib/infrastructure/mock/` | ✅ Phase 1 |
/// | [YoutubeExplodeMusicProvider] | `lib/infrastructure/youtube/` | 🚧 Phase 2 |
/// {@endtemplate}
abstract class MusicProvider {
  // =========================================================================
  // Identity — every provider must declare its capabilities
  // =========================================================================

  /// Human-readable name shown in Settings > About.
  /// Example: `'YouTube Music (youtube_explode_dart)'`
  String get providerName;

  /// SemVer string of this wrapper implementation (e.g., `'1.0.0'`).
  String get providerVersion;

  /// Whether this provider can return lyrics (timed LRC or plain text).
  ///
  /// Check this before calling [getLyrics] to avoid unnecessary network calls.
  bool get supportsLyrics;

  /// Whether this provider supports music video streams alongside audio.
  ///
  /// When `false`, [getMusicVideoUrl] must throw [VideoUnavailableException].
  /// The Now Playing screen hides the Audio/Video toggle when `false`.
  bool get supportsVideo;

  /// Whether this provider can return "related song" recommendations.
  ///
  /// When `false`, [getRecommendations] must return an empty list.
  /// [SmartShuffleEngine] falls back to pure Fisher-Yates when `false`.
  bool get supportsRecommendations;

  // =========================================================================
  // Search
  // =========================================================================

  /// Searches for songs matching [query].
  ///
  /// - [limit] controls the maximum number of results returned (default 20).
  /// - [page] enables cursor-based pagination (0-indexed).
  /// - Returns an **empty list** on no results — never throws for zero results.
  /// - Throws [NetworkException] on connectivity failure.
  /// - Throws [ParseException] if the API response cannot be decoded.
  Future<List<Song>> searchSongs(
    String query, {
    int limit = 20,
    int page = 0,
  });

  /// Searches for albums matching [query].
  ///
  /// Same pagination and error contract as [searchSongs].
  Future<List<Album>> searchAlbums(
    String query, {
    int limit = 20,
    int page = 0,
  });

  // =========================================================================
  // Streaming
  // =========================================================================

  /// Returns a direct, playable URL for the **audio-only** stream of [songId].
  ///
  /// ## Why audio-only?
  /// Requesting audio-only streams avoids video decoding entirely, saving
  /// significant CPU and battery (especially on mobile). Muxed streams
  /// (audio + video combined) are only used in music video mode.
  ///
  /// ## Quality degradation contract
  /// Implementations MUST try to honour [quality] and gracefully degrade:
  /// `lossless` → `high` → `medium` → `low` (never fail for quality reasons).
  ///
  /// ## URL expiry
  /// YouTube stream URLs expire after ~6 hours. The [AudioPlayerService]
  /// caches URLs and refreshes them before they expire using [AppConstants.streamUrlTtl].
  ///
  /// Throws [StreamUnavailableException] if no stream can be resolved.
  Future<String> getStreamUrl(
    String songId, {
    AudioQuality quality = AudioQuality.high,
  });

  /// Returns a direct, playable URL for the **music video** stream of [songId].
  ///
  /// Only call this after verifying `song.hasVideo == true`.
  /// The Now Playing screen uses `chewie` + `video_player` to render the stream.
  ///
  /// Throws [VideoUnavailableException] if [supportsVideo] is false or the
  /// video stream cannot be resolved.
  Future<String> getMusicVideoUrl(
    String songId, {
    VideoQuality quality = VideoQuality.p720,
  });

  // =========================================================================
  // Metadata
  // =========================================================================

  /// Fetches full metadata for a single song by its provider-specific [songId].
  ///
  /// Used when the caller has an ID but not the full [Song] object
  /// (e.g., loading a downloaded song from the local database).
  Future<Song> getSongDetails(String songId);

  /// Fetches full metadata for an album including its complete track listing.
  ///
  /// The returned [Album] will have a non-empty [Album.songs] list.
  Future<Album> getAlbumDetails(String albumId);

  // =========================================================================
  // Lyrics
  // =========================================================================

  /// Fetches lyrics for [songId].
  ///
  /// Returns `null` when:
  /// - [supportsLyrics] is `false`, or
  /// - Lyrics are not available for this track.
  ///
  /// Never throws for unavailable lyrics — the Now Playing screen shows a
  /// graceful "No lyrics available" state when `null` is returned.
  ///
  /// Providers should prefer returning [Lyrics.timedLines] (LRC format) over
  /// [Lyrics.plainText] when available, to enable the synchronized lyrics view.
  Future<Lyrics?> getLyrics(String songId);

  // =========================================================================
  // Discovery
  // =========================================================================

  /// Returns a list of songs similar to [songId].
  ///
  /// ## Smart Shuffle integration
  /// [SmartShuffleEngine] calls this method when the playback queue has
  /// ≤ [AppConstants.shuffleRefillThreshold] songs remaining. The returned
  /// songs are appended to the tail of the queue, creating the illusion of
  /// infinite, taste-aware playback — similar to YouTube Music's radio mode.
  ///
  /// [artistHint] — if provided, implementations may use it as the artist
  /// name for fallback searches, avoiding an extra network round-trip to
  /// look up metadata that the caller already has.
  ///
  /// Returns an empty list when [supportsRecommendations] is `false`.
  Future<List<Song>> getRecommendations(
    String songId, {
    int limit = 20,
    String? artistHint,
  });

  /// Returns currently trending / featured songs.
  ///
  /// Used on the Home screen's "Trending" section.
  /// [countryCode] is an optional ISO 3166-1 alpha-2 code (e.g., `'IN'`, `'US'`).
  Future<List<Song>> getTrending({
    String? countryCode,
    int limit = 20,
  });
}
