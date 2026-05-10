import 'package:arora/core/errors/exceptions.dart';
import 'package:arora/core/utils/logger.dart';
import 'package:arora/domain/entities/album.dart';
import 'package:arora/domain/entities/lyrics.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/enums/audio_quality.dart';
import 'package:arora/domain/enums/video_quality.dart';
import 'package:arora/domain/providers/music_provider.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

/// {@template youtube_explode_music_provider}
/// A fully implemented [MusicProvider] powered by `youtube_explode_dart`.
///
/// ## How it works (no API key required)
/// Uses `youtube_explode_dart` which reverse-engineers YouTube's internal API
/// — the same technique as yt-dlp. No quotas, no key needed, all platforms.
///
/// ## Music Video Strategy (Phase 2: Option A — HLS muxed)
/// Music video URLs are resolved via HLS (m3u8) muxed streams which contain
/// both audio and video in a single URL. This works out-of-the-box with
/// `chewie` / `video_player` on all platforms. Max quality is ~360p due to
/// YouTube's muxed stream limitation. HD video (Option B) is a Phase 3 goal.
///
/// ## Error handling
/// All `youtube_explode_dart` exceptions are caught and converted to typed
/// [AroraException] subclasses so the UI layer never sees raw yt errors.
/// {@endtemplate}
class YoutubeExplodeMusicProvider extends MusicProvider {
  /// [httpClient] — optional authenticated http.Client from [YoutubeAuthService].
  /// When provided, all YouTube requests carry valid OAuth tokens, eliminating
  /// IP-based rate limiting. Falls back to unauthenticated (guest) mode when null.
  // The authenticated http.Client carries googleapis OAuth headers that
  // InnerTube's player endpoint rejects with 403. YoutubeExplode gets a plain
  // unauthenticated client. Phase 2 (direct InnerTube calls) will use the
  // authenticated client directly without going through youtube_explode_dart.
  YoutubeExplodeMusicProvider([http.Client? httpClient])
      : _yt = yt.YoutubeExplode();

  final yt.YoutubeExplode _yt;
  static const _log = AroraLogger('YoutubeExplodeMusicProvider');

  // ── Identity ──────────────────────────────────────────────────────────────

  @override
  String get providerName => 'YouTube Music (youtube_explode_dart)';

  @override
  String get providerVersion => '1.0.0';

  @override
  bool get supportsLyrics => true;

  @override
  bool get supportsVideo => true;

  @override
  bool get supportsRecommendations => true;

  // ── Search ────────────────────────────────────────────────────────────────

  @override
  Future<List<Song>> searchSongs(
    String query, {
    int limit = 20,
    int page = 0,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      _log.debug('searchSongs: "$query" (limit=$limit, page=$page)');

      // youtube_explode_dart search returns a lazily-paginated SearchList.
      // We collect [limit] items, skipping [page * limit] for pagination.
      final searchList = await _yt.search.search(query);

      // TODO: Implement proper page-based cursor navigation using
      // searchList.nextPage() for page > 0.
      final songs = searchList
          .whereType<yt.Video>()
          .take(limit)
          .map(_videoToSong)
          .toList();

      _log.info('searchSongs: found ${songs.length} results for "$query"');
      return songs;
    } on yt.YoutubeExplodeException catch (e) {
      _log.error('searchSongs failed', error: e);
      throw NetworkException('YouTube search failed: ${e.message}');
    } catch (e) {
      _log.error('searchSongs unexpected error', error: e);
      throw ParseException('Failed to parse search results: $e');
    }
  }

  @override
  Future<List<Album>> searchAlbums(
    String query, {
    int limit = 20,
    int page = 0,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      _log.debug('searchAlbums: "$query"');

      // YouTube doesn't have a native album concept — we search for playlists
      // that represent albums (official topic channels or user playlists).
      final searchList = await _yt.search.search('$query album playlist');

      final playlists = searchList
          .whereType<yt.SearchPlaylist>()
          .take(limit)
          .map(_searchPlaylistToAlbum)
          .toList();

      _log.info('searchAlbums: found ${playlists.length} results');
      return playlists;
    } on yt.YoutubeExplodeException catch (e) {
      _log.error('searchAlbums failed', error: e);
      throw NetworkException('YouTube search failed: ${e.message}');
    } catch (e) {
      _log.error('searchAlbums unexpected error', error: e);
      throw ParseException('Failed to parse album results: $e');
    }
  }

  // ── Streaming ─────────────────────────────────────────────────────────────

  @override
  Future<String> getStreamUrl(
    String songId, {
    AudioQuality quality = AudioQuality.high,
  }) async {
    try {
      _log.debug('getStreamUrl: $songId (quality=$quality)');

      final manifest = await _yt.videos.streams
          .getManifest(songId)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw StreamUnavailableException(
              'Timed out fetching stream for $songId — check your connection.',
            ),
          );

      // YouTube's CDN restricts audio-only streams (opus/webm) to authenticated
      // app sessions — external players (mpv, ExoPlayer) get 403. Muxed streams
      // (video+audio mp4, itag=18/22) are served without session requirements and
      // are playable by all backends. just_audio extracts the audio track.
      final muxedStreams = manifest.muxed;
      if (muxedStreams.isEmpty) {
        throw StreamUnavailableException(
          'No playable streams found for video $songId.',
        );
      }

      // Pick best muxed stream by audio bitrate (highest audio quality).
      final muxedSorted = muxedStreams.toList()
        ..sort(
          (a, b) => b.bitrate.kiloBitsPerSecond
              .compareTo(a.bitrate.kiloBitsPerSecond),
        );
      final selected = muxedSorted.first;

      final url = selected.url.toString();
      _log.info(
        'getStreamUrl: resolved muxed ${selected.bitrate.kiloBitsPerSecond.round()} kbps '
        '${selected.videoCodec}+${selected.audioCodec} for $songId',
      );
      return url;
    } on StreamUnavailableException {
      rethrow;
    } on yt.YoutubeExplodeException catch (e) {
      _log.error('getStreamUrl failed for $songId', error: e);
      throw StreamUnavailableException(
        'Could not resolve stream for $songId: ${e.message}',
      );
    } catch (e) {
      _log.error('getStreamUrl unexpected error for $songId', error: e);
      throw StreamUnavailableException('Stream resolution failed: $e');
    }
  }

  @override
  Future<String> getMusicVideoUrl(
    String songId, {
    VideoQuality quality = VideoQuality.p720,
  }) async {
    try {
      _log.debug('getMusicVideoUrl: $songId (quality=$quality)');

      final manifest = await _yt.videos.streams.getManifest(songId);

      // Strategy: Option B — Adaptive HD Stream (Video-only).
      // We extract the high-quality video-only stream from YouTube.
      // The audio is played simultaneously via just_audio in the background.
      final videoStreams = manifest.videoOnly;
      if (videoStreams.isEmpty) {
        // Fallback: muxed streams (limited to 360p on YouTube).
        final muxed = manifest.muxed;
        if (muxed.isEmpty) {
          throw VideoUnavailableException(
            'No video streams found for video $songId.',
          );
        }
        var bestMuxed = muxed.first;
        for (final s in muxed) {
          if (s.size.totalBytes > bestMuxed.size.totalBytes) {
            bestMuxed = s;
          }
        }
        _log.info('getMusicVideoUrl: using fallback muxed stream for $songId');
        return bestMuxed.url.toString();
      }

      // Sort video streams by resolution height descending
      final sortedVideos = videoStreams.toList()
        ..sort((a, b) => b.videoResolution.height.compareTo(a.videoResolution.height));

      final targetHeight = switch (quality) {
        VideoQuality.p360 => 360,
        VideoQuality.p720 => 720,
        VideoQuality.p1080 => 1080,
      };

      // Find the first stream that is <= targetHeight
      // If none found, just use the lowest available (last in sorted list)
      yt.VideoOnlyStreamInfo selected = sortedVideos.first;
      for (final s in sortedVideos) {
        if (s.videoResolution.height <= targetHeight) {
          selected = s;
          break;
        }
      }

      final url = selected.url.toString();
      _log.info(
        'getMusicVideoUrl: using videoOnly stream (${selected.videoResolution.height}p) for $songId',
      );
      return url;
    } on VideoUnavailableException {
      rethrow;
    } on yt.YoutubeExplodeException catch (e) {
      _log.error('getMusicVideoUrl failed for $songId', error: e);
      throw VideoUnavailableException(
        'Could not resolve video stream for $songId: ${e.message}',
      );
    } catch (e) {
      _log.error('getMusicVideoUrl unexpected error', error: e);
      throw VideoUnavailableException('Video stream resolution failed: $e');
    }
  }

  // ── Metadata ──────────────────────────────────────────────────────────────

  @override
  Future<Song> getSongDetails(String songId) async {
    try {
      _log.debug('getSongDetails: $songId');
      final video = await _yt.videos.get(songId);
      return _videoToSong(video);
    } on yt.VideoUnplayableException catch (e) {
      throw StreamUnavailableException('Video $songId is unplayable: $e');
    } on yt.YoutubeExplodeException catch (e) {
      _log.error('getSongDetails failed for $songId', error: e);
      throw NetworkException('Failed to fetch song details: ${e.message}');
    }
  }

  @override
  Future<Album> getAlbumDetails(String albumId) async {
    try {
      _log.debug('getAlbumDetails: $albumId (treated as playlist ID)');

      // On YouTube, albums are represented as playlists.
      final playlist = await _yt.playlists.get(albumId);
      final videos = await _yt.playlists
          .getVideos(albumId)
          .take(50)
          .toList();

      return _playlistToAlbum(playlist, videos);
    } on yt.YoutubeExplodeException catch (e) {
      _log.error('getAlbumDetails failed for $albumId', error: e);
      throw NetworkException('Failed to fetch album details: ${e.message}');
    }
  }

  // ── Lyrics ────────────────────────────────────────────────────────────────

  @override
  Future<Lyrics?> getLyrics(String songId) async {
    try {
      _log.debug('getLyrics: $songId');

      final manifest =
          await _yt.videos.closedCaptions.getManifest(songId);

      if (manifest.tracks.isEmpty) {
        _log.debug('getLyrics: no caption tracks for $songId');
        return null;
      }

      // Prefer English captions; fall back to first available language.
      yt.ClosedCaptionTrackInfo? trackInfo;
      for (final track in manifest.tracks) {
        if (track.language.name.toLowerCase().contains('english') || 
            track.language.code.toLowerCase().startsWith('en')) {
          trackInfo = track;
          break;
        }
      }
      trackInfo ??= manifest.tracks.firstOrNull;

      if (trackInfo == null) return null;

      final track = await _yt.videos.closedCaptions.get(trackInfo);

      if (track.captions.isEmpty) return null;

      // Map YouTube ClosedCaption entries → LyricLine entities.
      // YouTube auto-generated captions have timing data suitable for sync.
      final lines = track.captions
          .map(
            (c) => LyricLine(
              startMs: c.offset.inMilliseconds,
              text: c.text.trim(),
            ),
          )
          .where((line) => line.text.isNotEmpty)
          .toList();

      _log.info(
        'getLyrics: resolved ${lines.length} timed lines '
        '(lang: ${trackInfo.language.name}) for $songId',
      );

      return Lyrics(
        timedLines: lines,
        language: trackInfo.language.name,
      );
    } on yt.YoutubeExplodeException catch (e) {
      // Lyrics failing is non-fatal — return null gracefully.
      _log.warn('getLyrics: captions unavailable for $songId', error: e);
      return null;
    } catch (e) {
      _log.warn('getLyrics: unexpected error for $songId', error: e);
      return null;
    }
  }

  // ── Discovery ─────────────────────────────────────────────────────────────

  @override
  Future<List<Song>> getRecommendations(
    String songId, {
    int limit = 20,
    String? artistHint,
  }) async {
    try {
      _log.debug('getRecommendations: seed=$songId limit=$limit');

      // YouTube auto-generates a "Radio Mix" playlist for every video using
      // the ID format RD{videoId}. This is far more reliable than
      // getRelatedVideos(), which returns null for most videos.
      final mixPlaylistId = 'RD$songId';
      final videos = await _yt.playlists
          .getVideos(mixPlaylistId)
          .where((v) => v.id.value != songId)
          .take(limit)
          .toList();

      if (videos.isNotEmpty) {
        final songs = videos.map(_videoToSong).toList();
        _log.info('getRecommendations: ${songs.length} songs via Radio Mix');
        return songs;
      }

      // Fallback: search by artist name. Use the hint from the caller if
      // available — avoids an extra _yt.videos.get() request for metadata
      // we already have, which can trigger YouTube rate limiting.
      _log.debug('getRecommendations: Radio Mix empty, falling back to artist search');
      final String artist;
      if (artistHint != null && artistHint.isNotEmpty) {
        artist = artistHint;
      } else {
        final video = await _yt.videos.get(songId);
        final (a, _) = _parseArtistTitle(video.title, video.author);
        artist = a;
      }
      final results = await searchSongs('$artist music', limit: limit + 1);
      final filtered =
          results.where((s) => s.id != songId).take(limit).toList();
      _log.info('getRecommendations: ${filtered.length} songs via artist search fallback');
      return filtered;
    } on yt.YoutubeExplodeException catch (e) {
      _log.warn('getRecommendations failed for $songId', error: e);
      return [];
    } catch (e) {
      _log.warn('getRecommendations unexpected error', error: e);
      return [];
    }
  }

  @override
  Future<List<Song>> getTrending({
    String? countryCode,
    int limit = 20,
  }) async {
    try {
      _log.debug('getTrending: countryCode=$countryCode limit=$limit');

      // YouTube Music trending playlist ID (global).
      // This is YouTube Music's official "Top Songs" chart playlist.
      const trendingPlaylistId = 'PLFgquLnL59alCl_2TQvOiD5Vgm1hCaGSI';

      final videos = await _yt.playlists
          .getVideos(trendingPlaylistId)
          .take(limit)
          .toList();

      final songs = videos.map(_videoToSong).toList();
      _log.info('getTrending: returned ${songs.length} songs');
      return songs;
    } on yt.YoutubeExplodeException catch (e) {
      _log.warn('getTrending failed, falling back to search', error: e);
      // Fallback: search for "top hits" if playlist fails
      try {
        return searchSongs('top hits 2024 music', limit: limit);
      } catch (_) {
        return [];
      }
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Maps a [yt.Video] to an Arora [Song] entity.
  ///
  /// All YouTube videos are treated as potentially having a music video
  /// since they are inherently video content.
  Song _videoToSong(yt.Video v) {
    // Extract artist from "Artist - Title" format common on YouTube Music.
    final (artist, title) = _parseArtistTitle(v.title, v.author);

    // Best available thumbnail — prefer maxRes, fallback through sizes.
    final thumb = v.thumbnails.highResUrl;

    return Song(
      id: v.id.value,
      title: title,
      artistName: artist,
      albumName: null, // YouTube doesn't expose album info on Video
      thumbnailUrl: thumb,
      durationMs: v.duration?.inMilliseconds,
      // All YouTube songs can be played as video (they ARE videos).
      hasVideo: true,
      videoId: v.id.value,
    );
  }

  /// Maps a [yt.SearchPlaylist] stub to an Arora [Album].
  ///
  /// Note: SearchPlaylist has minimal data. [getAlbumDetails] fetches full info.
  Album _searchPlaylistToAlbum(yt.SearchPlaylist p) => Album(
        id: p.id.value,
        title: p.title,
        artistName: 'Various Artists',
        thumbnailUrl: p.thumbnails.isNotEmpty ? p.thumbnails.last.url.toString() : null,
        trackCount: p.videoCount,
      );

  /// Maps a fully fetched [yt.Playlist] + its videos to an [Album].
  Album _playlistToAlbum(yt.Playlist p, List<yt.Video> videos) => Album(
        id: p.id.value,
        title: p.title,
        artistName: p.author.isNotEmpty ? p.author : 'Various Artists',
        thumbnailUrl: p.thumbnails.highResUrl,
        trackCount: videos.length,
        songs: videos.map(_videoToSong).toList(),
      );

  /// Attempts to split a YouTube video title into (artist, trackTitle).
  ///
  /// YouTube Music typically formats titles as "Artist - Track Title" or
  /// "Track Title (Official Video)". This heuristic handles the common cases.
  (String artist, String title) _parseArtistTitle(
    String rawTitle,
    String channelName,
  ) {
    // Common separator: " - " (artist dash title)
    final dashIndex = rawTitle.indexOf(' - ');
    if (dashIndex > 0) {
      final artist = rawTitle.substring(0, dashIndex).trim();
      var title = rawTitle.substring(dashIndex + 3).trim();
      // Strip common suffixes: "(Official Video)", "(Lyric Video)", etc.
      title = title
          .replaceAll(
            RegExp(
              r'\s*\((official|lyric|music|video|audio|hd|4k)[^)]*\)',
              caseSensitive: false,
            ),
            '',
          )
          .trim();
      return (artist, title);
    }

    // Fallback: use channel name as artist, raw title as track title.
    // Strip " - Topic" suffix from auto-generated music channels.
    final artist = channelName.replaceAll(RegExp(r'\s*-\s*Topic$'), '').trim();
    return (artist, rawTitle);
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Releases the underlying HTTP client.
  ///
  /// Called automatically by Riverpod's `ref.onDispose` in `lib/app.dart`.
  void dispose() {
    _yt.close();
    _log.info('YoutubeExplode HTTP client closed.');
  }
}
