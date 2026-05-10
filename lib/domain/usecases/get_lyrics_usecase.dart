import 'package:arora/domain/entities/lyrics.dart';
import 'package:arora/domain/providers/music_provider.dart';

/// Fetches lyrics for a song from the active [MusicProvider].
///
/// Returns `null` gracefully when lyrics are unavailable — the Now Playing
/// screen shows a "No lyrics available" placeholder in that case.
final class GetLyricsUseCase {
  const GetLyricsUseCase(this._provider);

  final MusicProvider _provider;

  /// Returns [Lyrics] for [songId], or `null` if unavailable.
  ///
  /// Callers should check [MusicProvider.supportsLyrics] first to avoid
  /// unnecessary network calls when the provider cannot return lyrics.
  Future<Lyrics?> call(String songId) async {
    if (!_provider.supportsLyrics) return null;
    return _provider.getLyrics(songId);
  }
}
