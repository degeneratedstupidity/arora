import 'package:flutter_test/flutter_test.dart';
import 'package:arora/infrastructure/mock/mock_music_provider.dart';

void main() {
  late MockMusicProvider provider;

  setUp(() {
    provider = MockMusicProvider();
  });

  // ── Identity ──────────────────────────────────────────────────────────────

  group('MockMusicProvider — identity', () {
    test('providerName is non-empty', () {
      expect(provider.providerName, isNotEmpty);
    });

    test('supportsVideo is true', () {
      expect(provider.supportsVideo, isTrue);
    });

    test('supportsLyrics is true', () {
      expect(provider.supportsLyrics, isTrue);
    });

    test('supportsRecommendations is true', () {
      expect(provider.supportsRecommendations, isTrue);
    });
  });

  // ── Search ────────────────────────────────────────────────────────────────

  group('MockMusicProvider — searchSongs', () {
    test('returns results for a matching query', () async {
      final results = await provider.searchSongs('Aurora');
      expect(results, isNotEmpty);
      expect(results.first.title, contains('Aurora'));
    });

    test('returns empty list for non-matching query', () async {
      final results = await provider.searchSongs('xyznonexistent');
      expect(results, isEmpty);
    });

    test('returns empty list for empty query', () async {
      final results = await provider.searchSongs('');
      expect(results, isEmpty);
    });

    test('respects limit parameter', () async {
      final results = await provider.searchSongs('a', limit: 2);
      expect(results.length, lessThanOrEqualTo(2));
    });
  });

  group('MockMusicProvider — searchAlbums', () {
    test('returns albums matching query', () async {
      final results = await provider.searchAlbums('Neon');
      expect(results, isNotEmpty);
      expect(results.first.title, contains('Neon'));
    });
  });

  // ── Streaming ─────────────────────────────────────────────────────────────

  group('MockMusicProvider — getStreamUrl', () {
    test('returns a non-empty URL', () async {
      final url = await provider.getStreamUrl('mock-1');
      expect(url, isNotEmpty);
      expect(url, startsWith('http'));
    });
  });

  group('MockMusicProvider — getMusicVideoUrl', () {
    test('returns a video URL for a song with hasVideo=true', () async {
      final url = await provider.getMusicVideoUrl('mock-1');
      expect(url, isNotEmpty);
      expect(url, startsWith('http'));
    });

    test('throws VideoUnavailableException for a song with no video', () async {
      expect(
        () => provider.getMusicVideoUrl('mock-2'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ── Metadata ──────────────────────────────────────────────────────────────

  group('MockMusicProvider — getSongDetails', () {
    test('returns song for valid ID', () async {
      final song = await provider.getSongDetails('mock-1');
      expect(song.id, equals('mock-1'));
    });

    test('throws for unknown song ID', () async {
      expect(
        () => provider.getSongDetails('unknown-id'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ── Lyrics ────────────────────────────────────────────────────────────────

  group('MockMusicProvider — getLyrics', () {
    test('returns timed lyrics for mock-1', () async {
      final lyrics = await provider.getLyrics('mock-1');
      expect(lyrics, isNotNull);
      expect(lyrics!.isSynced, isTrue);
      expect(lyrics.timedLines, isNotEmpty);
    });

    test('returns plain-text lyrics for mock-2', () async {
      final lyrics = await provider.getLyrics('mock-2');
      expect(lyrics, isNotNull);
      expect(lyrics!.isSynced, isFalse);
      expect(lyrics.plainText, isNotEmpty);
    });

    test('returns null for a track with no lyrics', () async {
      final lyrics = await provider.getLyrics('mock-4');
      expect(lyrics, isNull);
    });
  });

  // ── Discovery ─────────────────────────────────────────────────────────────

  group('MockMusicProvider — getRecommendations', () {
    test('returns songs excluding the seed', () async {
      final recs = await provider.getRecommendations('mock-1');
      expect(recs, isNotEmpty);
      expect(recs.any((s) => s.id == 'mock-1'), isFalse);
    });
  });

  group('MockMusicProvider — getTrending', () {
    test('returns non-empty list', () async {
      final trending = await provider.getTrending();
      expect(trending, isNotEmpty);
    });
  });
}
