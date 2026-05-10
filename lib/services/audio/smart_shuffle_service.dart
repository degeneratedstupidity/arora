import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arora/services/audio/playback_queue_notifier.dart';
import 'package:arora/domain/entities/playback_queue.dart';
import 'package:arora/features/player/providers/player_providers.dart';

part 'smart_shuffle_service.g.dart';

@Riverpod(keepAlive: true)
class SmartShuffleService extends _$SmartShuffleService {
  bool _isFetching = false;
  static const _threshold = 2; // Fetch when 2 or fewer songs remain

  @override
  void build() {
    // Listen to changes in the queue to trigger refills
    ref.listen(playbackQueueProvider, (previous, next) {
      // Only check if the index progressed or shuffle was just enabled
      if (previous?.currentIndex != next.currentIndex || 
          (previous?.isSmartShuffleEnabled == false && next.isSmartShuffleEnabled)) {
        _checkQueueAndRefill(next);
      }
    });
  }

  Future<void> _checkQueueAndRefill(PlaybackQueue queue) async {
    if (!queue.isSmartShuffleEnabled) return;
    if (queue.songs.isEmpty || queue.currentSong == null) return;
    
    final remaining = queue.songs.length - 1 - queue.currentIndex;
    
    if (remaining <= _threshold && !_isFetching) {
      _isFetching = true;
      try {
        final musicProvider = ref.read(musicProviderProvider);
        
        if (!musicProvider.supportsRecommendations) return;

        // Fetch AI recommendations based on the current song
        final recommendations = await musicProvider.getRecommendations(
          queue.currentSong!.id,
          limit: 10,
          artistHint: queue.currentSong!.artistName,
        );
        
        // Append them to the tail of the queue
        ref.read(playbackQueueProvider.notifier).addAllLast(recommendations);
      } catch (e) {
        // Silently fail if recommendations cannot be fetched right now (e.g. offline)
      } finally {
        _isFetching = false;
      }
    }
  }
}