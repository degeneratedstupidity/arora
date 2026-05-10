import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arora/domain/entities/lyrics.dart';

part 'cache_service.g.dart';

/// A centralized memory cache for API responses.
class CacheService {
  final Map<String, (String, DateTime)> _urlCache = {};
  final Map<String, (Lyrics, DateTime)> _lyricsCache = {};

  static const _urlTtl = Duration(hours: 1);
  static const _lyricsTtl = Duration(hours: 24);

  String? getStreamUrl(String songId) {
    final cached = _urlCache[songId];
    if (cached != null) {
      final (url, fetchedAt) = cached;
      if (DateTime.now().difference(fetchedAt) < _urlTtl) {
        return url;
      } else {
        _urlCache.remove(songId);
      }
    }
    return null;
  }

  void saveStreamUrl(String songId, String url) {
    _urlCache[songId] = (url, DateTime.now());
  }

  Lyrics? getLyrics(String songId) {
    final cached = _lyricsCache[songId];
    if (cached != null) {
      final (lyrics, fetchedAt) = cached;
      if (DateTime.now().difference(fetchedAt) < _lyricsTtl) {
        return lyrics;
      } else {
        _lyricsCache.remove(songId);
      }
    }
    return null;
  }

  void saveLyrics(String songId, Lyrics lyrics) {
    _lyricsCache[songId] = (lyrics, DateTime.now());
  }
}

@Riverpod(keepAlive: true)
CacheService cacheService(Ref ref) {
  return CacheService();
}