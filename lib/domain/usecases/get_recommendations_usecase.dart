import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/providers/music_provider.dart';

/// Fetches song recommendations to feed the Smart Shuffle tail queue.
///
/// Called by [SmartShuffleEngine] when the playback queue falls below
/// [AppConstants.shuffleRefillThreshold] remaining songs.
final class GetRecommendationsUseCase {
  const GetRecommendationsUseCase(this._provider);

  final MusicProvider _provider;

  /// Returns songs similar to [seedSongId].
  ///
  /// Returns an empty list when [MusicProvider.supportsRecommendations] is false.
  /// [SmartShuffleEngine] falls back to Fisher-Yates re-shuffle in that case.
  Future<List<Song>> call(
    String seedSongId, {
    int limit = 10,
  }) async {
    if (!_provider.supportsRecommendations) return [];
    return _provider.getRecommendations(seedSongId, limit: limit);
  }
}
