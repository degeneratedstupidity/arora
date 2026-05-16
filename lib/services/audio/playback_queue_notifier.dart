import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arora/domain/entities/playback_queue.dart';
import 'package:arora/domain/entities/song.dart';

part 'playback_queue_notifier.g.dart';

@Riverpod(keepAlive: true)
class PlaybackQueueNotifier extends _$PlaybackQueueNotifier {
  @override
  PlaybackQueue build() {
    return const PlaybackQueue();
  }

  void playSong(Song song) {
    state = state.copyWith(
      songs: [song],
      currentIndex: 0,
    );
  }

  void playPlaylist(List<Song> playlist, {int initialIndex = 0}) {
    state = state.copyWith(
      songs: playlist,
      currentIndex: initialIndex,
    );
  }

  void addAllLast(List<Song> newSongs) {
    // Filter out tracks that are already in the queue to prevent loops
    final existingIds = state.songs.map((s) => s.id).toSet();
    final uniqueSongs = newSongs.where((s) => !existingIds.contains(s.id)).toList();
    
    if (uniqueSongs.isNotEmpty) {
      state = state.copyWith(songs: [...state.songs, ...uniqueSongs]);
    }
  }

  /// Replaces every song after the current index with [songs].
  /// Used by SmartShuffleService on force-refresh so the upcoming queue
  /// is exactly the new batch (no stale leftover songs ahead).
  void replaceUpcoming(List<Song> songs) {
    final kept = state.songs.take(state.currentIndex + 1).toList();
    final existingIds = kept.map((s) => s.id).toSet();
    final unique = songs.where((s) => !existingIds.contains(s.id)).toList();
    state = state.copyWith(songs: [...kept, ...unique]);
  }

  void toggleSmartShuffle() {
    state = state.copyWith(isSmartShuffleEnabled: !state.isSmartShuffleEnabled);
  }

  void next() {
    if (state.songs.isEmpty) return;
    // Wrap to beginning when at the last track so the queue is always navigable.
    final nextIndex = (state.currentIndex + 1) % state.songs.length;
    state = state.copyWith(currentIndex: nextIndex);
  }

  void previous() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }
}