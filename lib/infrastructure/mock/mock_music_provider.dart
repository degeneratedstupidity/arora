import 'package:arora/core/errors/exceptions.dart';
import 'package:arora/domain/entities/album.dart';
import 'package:arora/domain/entities/lyrics.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/enums/audio_quality.dart';
import 'package:arora/domain/enums/video_quality.dart';
import 'package:arora/domain/providers/music_provider.dart';

/// {@template mock_music_provider}
/// A fully self-contained mock implementation of [MusicProvider].
///
/// ## Purpose
/// This provider powers all Phase 1 UI and business-logic development
/// without making any real network calls. It returns hardcoded but
/// realistic data so that:
///
/// - Every screen can be built and iterated on immediately.
/// - Unit tests run offline, instantly, with zero flakiness.
/// - The [SmartShuffleEngine] can be developed and tested end-to-end.
///
/// ## What it provides
/// - 6 songs (2 with `hasVideo = true`)
/// - 2 albums
/// - Timed LRC lyrics for one track (for the synchronized lyrics view)
/// - A real publicly available `.mp3` test URL (so audio actually plays)
/// - Simulated 200ms latency to mimic real network feel during UI dev
/// {@endtemplate}
class MockMusicProvider extends MusicProvider {
  // ── Identity ──────────────────────────────────────────────────────────────

  @override
  String get providerName => 'Mock Provider';

  @override
  String get providerVersion => '1.0.0';

  @override
  bool get supportsLyrics => true;

  @override
  bool get supportsVideo => true;

  @override
  bool get supportsRecommendations => true;

  // ── Internal fake delay ───────────────────────────────────────────────────

  /// Simulates a real network round-trip to expose any loading state issues.
  static Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 200));

  // ── Seed data ─────────────────────────────────────────────────────────────

  static final List<Song> _songs = [
    const Song(
      id: 'mock-1',
      title: 'Aurora Dreams',
      artistName: 'Celeste Nova',
      albumName: 'Neon Horizons',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
      durationMs: 227000, // 3:47
      hasVideo: true,
      videoId: 'mock-1',
    ),
    const Song(
      id: 'mock-2',
      title: 'Midnight Circuit',
      artistName: 'Synthwave Atlas',
      albumName: 'Neon Horizons',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400',
      durationMs: 194000, // 3:14
      hasVideo: false,
    ),
    const Song(
      id: 'mock-3',
      title: 'Glass Ocean',
      artistName: 'Elara Sound',
      albumName: 'Depths',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=400',
      durationMs: 312000, // 5:12
      hasVideo: true,
      videoId: 'mock-3',
    ),
    const Song(
      id: 'mock-4',
      title: 'Neon Boulevard',
      artistName: 'Celeste Nova',
      albumName: 'Neon Horizons',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1614854262318-831574f15f1f?w=400',
      durationMs: 241000, // 4:01
      hasVideo: false,
    ),
    const Song(
      id: 'mock-5',
      title: 'Fractal Mind',
      artistName: 'Synthwave Atlas',
      albumName: 'Recursion',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=400',
      durationMs: 278000, // 4:38
      hasVideo: false,
    ),
    const Song(
      id: 'mock-6',
      title: 'Stellar Drift',
      artistName: 'Elara Sound',
      albumName: 'Depths',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1446776877081-d282a0f896e2?w=400',
      durationMs: 356000, // 5:56
      hasVideo: false,
    ),
  ];

  static final List<Album> _albums = [
    Album(
      id: 'album-1',
      title: 'Neon Horizons',
      artistName: 'Celeste Nova',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
      releaseYear: 2024,
      trackCount: 3,
      songs: _songs.where((s) => s.albumName == 'Neon Horizons').toList(),
    ),
    Album(
      id: 'album-2',
      title: 'Depths',
      artistName: 'Elara Sound',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=400',
      releaseYear: 2023,
      trackCount: 2,
      songs: _songs.where((s) => s.albumName == 'Depths').toList(),
    ),
  ];

  /// Timed LRC lyrics for 'Aurora Dreams' (mock-1).
  ///
  /// Format matches the [LyricLine] entity for the synchronized lyrics view.
  static const Lyrics _auroraLyrics = Lyrics(
    timedLines: [
      LyricLine(startMs: 0,     text: '♪ Aurora Dreams ♪'),
      LyricLine(startMs: 5000,  text: 'Lights dancing across the frozen sky'),
      LyricLine(startMs: 10000, text: 'Colors I have never seen with open eyes'),
      LyricLine(startMs: 16000, text: 'The world below is sleeping'),
      LyricLine(startMs: 21000, text: 'While heaven writes in light'),
      LyricLine(startMs: 27000, text: 'Aurora, aurora'),
      LyricLine(startMs: 32000, text: 'Paint the night for me'),
      LyricLine(startMs: 38000, text: 'Aurora, aurora'),
      LyricLine(startMs: 43000, text: 'Set my spirit free'),
      LyricLine(startMs: 50000, text: 'I drift above the mountain peaks'),
      LyricLine(startMs: 55000, text: 'Chasing ribbons made of dreams'),
      LyricLine(startMs: 62000, text: 'Every shade of violet and green'),
      LyricLine(startMs: 68000, text: 'The most beautiful thing I have seen'),
    ],
    language: 'en',
  );

  // ── MusicProvider implementation ──────────────────────────────────────────

  @override
  Future<List<Song>> searchSongs(
    String query, {
    int limit = 20,
    int page = 0,
  }) async {
    await _delay();
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _songs
        .where(
          (s) =>
              s.title.toLowerCase().contains(q) ||
              s.artistName.toLowerCase().contains(q) ||
              (s.albumName?.toLowerCase().contains(q) ?? false),
        )
        .take(limit)
        .toList();
  }

  @override
  Future<List<Album>> searchAlbums(
    String query, {
    int limit = 20,
    int page = 0,
  }) async {
    await _delay();
    final q = query.toLowerCase();
    return _albums
        .where(
          (a) =>
              a.title.toLowerCase().contains(q) ||
              a.artistName.toLowerCase().contains(q),
        )
        .take(limit)
        .toList();
  }

  @override
  Future<String> getStreamUrl(
    String songId, {
    AudioQuality quality = AudioQuality.high,
  }) async {
    await _delay();
    // A real, publicly available MP3 for testing audio playback:
    // Source: University of Michigan test file (CC0)
    return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  }

  @override
  Future<String> getMusicVideoUrl(
    String songId, {
    VideoQuality quality = VideoQuality.p720,
  }) async {
    await _delay();
    if (songId != 'mock-1' && songId != 'mock-3') {
      throw const VideoUnavailableException(
        'No music video available for this mock track.',
      );
    }
    // A real, publicly available MP4 for testing video playback:
    // Source: file-examples.com (free test file)
    return 'https://file-examples.com/storage/fe8c11ddaf65c1fa25c5b82/2017/04/file_example_MP4_480_1_5MG.mp4';
  }

  @override
  Future<Song> getSongDetails(String songId) async {
    await _delay();
    return _songs.firstWhere(
      (s) => s.id == songId,
      orElse: () => throw NotFoundException('Song $songId not found in mock data.'),
    );
  }

  @override
  Future<Album> getAlbumDetails(String albumId) async {
    await _delay();
    return _albums.firstWhere(
      (a) => a.id == albumId,
      orElse: () => throw NotFoundException('Album $albumId not found in mock data.'),
    );
  }

  @override
  Future<Lyrics?> getLyrics(String songId) async {
    await _delay();
    if (songId == 'mock-1') return _auroraLyrics;
    // Other tracks return plain-text lyrics for variety:
    if (songId == 'mock-2') {
      return const Lyrics(
        plainText: 'Midnight Circuit\n\nDriving through the city in the dark\n'
            'Neon lights reflecting off the rain\n'
            'Every traffic signal is a spark\n'
            'Pulling me back into the fast lane.',
        language: 'en',
      );
    }
    return null; // Simulate no lyrics available for other tracks
  }

  @override
  Future<List<Song>> getRecommendations(
    String songId, {
    int limit = 20,
    String? artistHint,
  }) async {
    await _delay();
    // Return all songs except the seed song
    return _songs.where((s) => s.id != songId).take(limit).toList();
  }

  @override
  Future<List<Song>> getTrending({
    String? countryCode,
    int limit = 20,
  }) async {
    await _delay();
    return _songs.take(limit).toList();
  }
}
