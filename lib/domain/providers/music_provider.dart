import 'package:arora/domain/entities/album.dart';
import 'package:arora/domain/entities/lyrics.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/enums/audio_quality.dart';
import 'package:arora/domain/enums/video_quality.dart';

/// Abstract contract every music backend must implement.
/// Register a concrete class in `lib/app.dart` via `musicProviderProvider`.
abstract class MusicProvider {
  String get providerName;
  String get providerVersion;

  /// False → getLyrics may return null without a network call.
  bool get supportsLyrics;

  /// False → getMusicVideoUrl throws; Now Playing hides the Video tab.
  bool get supportsVideo;

  /// False → getRecommendations returns []; SmartShuffleService uses genre search only.
  bool get supportsRecommendations;

  Future<List<Song>> searchSongs(String query, {int limit = 20, int page = 0});

  Future<List<Album>> searchAlbums(String query, {int limit = 20, int page = 0});

  /// Returns a playable muxed stream URL. Expires after ~6 h.
  Future<String> getStreamUrl(String songId, {AudioQuality quality = AudioQuality.high});

  Future<String> getMusicVideoUrl(String songId, {VideoQuality quality = VideoQuality.p720});

  Future<Song> getSongDetails(String songId);

  Future<Album> getAlbumDetails(String albumId);

  /// Returns null when lyrics are unavailable. Never throws for missing lyrics.
  Future<Lyrics?> getLyrics(String songId);

  /// [artistHint] lets implementations skip an extra metadata round-trip.
  /// [useSearchFallback] — when false, skip the artist-search fallback and
  /// return [] if the Radio Mix playlist is empty. Set to false in hot paths
  /// (SmartShuffleService) to avoid stacking search API calls on stream fetches.
  Future<List<Song>> getRecommendations(
    String songId, {
    int limit = 20,
    String? artistHint,
    bool useSearchFallback = true,
  });

  Future<List<Song>> getTrending({String? countryCode, int limit = 20});
}
