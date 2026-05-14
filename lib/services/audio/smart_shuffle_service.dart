import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arora/services/audio/playback_queue_notifier.dart';
import 'package:arora/domain/entities/playback_queue.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/player/providers/player_providers.dart';

part 'smart_shuffle_service.g.dart';

@Riverpod(keepAlive: true)
class SmartShuffleService extends _$SmartShuffleService {
  bool _isFetching = false;

  // Refill when this many songs remain after the current index.
  static const _threshold = 3;

  // Songs to request per seed call.
  static const _batchSize = 15;

  // How many recently played songs to keep as alternate seeds.
  static const _maxSeedHistory = 5;

  // Songs that played before the current one, newest first.
  // Used as alternate seeds to keep the mix varied when the primary
  // Radio Mix returns songs we've already queued.
  final List<Song> _recentSeeds = [];

  @override
  void build() {
    ref.listen(playbackQueueProvider, (previous, next) {
      // Record the song that just finished when the queue index advances.
      if (previous != null && previous.currentIndex != next.currentIndex) {
        final justPlayed = previous.currentSong;
        if (justPlayed != null) {
          _recentSeeds.removeWhere((s) => s.id == justPlayed.id);
          _recentSeeds.insert(0, justPlayed);
          if (_recentSeeds.length > _maxSeedHistory) {
            _recentSeeds.removeLast();
          }
        }
      }

      // Check whether the queue needs a refill.
      if (previous?.currentIndex != next.currentIndex ||
          (previous?.isSmartShuffleEnabled == false &&
              next.isSmartShuffleEnabled)) {
        _checkQueueAndRefill(next);
      }
    });
  }

  Future<void> _checkQueueAndRefill(PlaybackQueue queue) async {
    if (!queue.isSmartShuffleEnabled) return;
    if (queue.songs.isEmpty || queue.currentSong == null) return;
    if (_isFetching) return;

    final remaining = queue.songs.length - 1 - queue.currentIndex;
    if (remaining > _threshold) return;

    _isFetching = true;
    try {
      final musicProvider = ref.read(musicProviderProvider);
      if (!musicProvider.supportsRecommendations) return;

      final currentSong = queue.currentSong!;
      final existingIds = queue.songs.map((s) => s.id).toSet();

      // ── Primary seed: current song (YouTube Radio Mix) ─────────────────
      final primaryRecs = await musicProvider.getRecommendations(
        currentSong.id,
        limit: _batchSize,
        artistHint: currentSong.artistName,
      );
      final newFromPrimary =
          primaryRecs.where((s) => !existingIds.contains(s.id)).toList();

      var finalRecs = newFromPrimary;

      // ── Alternate seed: a recently played song from a different artist ──
      // Only used when the primary Radio Mix is exhausted (< 3 new tracks),
      // to avoid doubling YouTube API calls during normal playback.
      if (newFromPrimary.length < 3) {
        final altSeed = _findAlternateSeed(currentSong);
        if (altSeed != null) {
          try {
            final altRecs = await musicProvider.getRecommendations(
              altSeed.id,
              limit: _batchSize,
              artistHint: altSeed.artistName,
            );
            final newFromAlt = altRecs.where((s) =>
                !existingIds.contains(s.id) &&
                !finalRecs.any((r) => r.id == s.id),);
            finalRecs = [...finalRecs, ...newFromAlt];
          } catch (_) {
            // Alternate seed failing is non-fatal — use whatever primary gave us.
          }
        }
      }

      if (finalRecs.isEmpty) return;

      ref.read(playbackQueueProvider.notifier)
          .addAllLast(finalRecs.take(_batchSize).toList());
    } catch (_) {
      // Silently fail if offline or API unavailable.
    } finally {
      _isFetching = false;
    }
  }

  /// Returns the most recent seed whose artist differs from [currentSong].
  ///
  /// Choosing a different artist prevents the queue from being dominated
  /// by a single act when the Radio Mix for one song keeps returning the
  /// same material.
  Song? _findAlternateSeed(Song currentSong) {
    for (final seed in _recentSeeds) {
      if (seed.id != currentSong.id &&
          seed.artistName != currentSong.artistName) {
        return seed;
      }
    }
    return null;
  }
}
