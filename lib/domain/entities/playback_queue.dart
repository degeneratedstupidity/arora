import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arora/domain/entities/song.dart';

part 'playback_queue.freezed.dart';

@freezed
abstract class PlaybackQueue with _$PlaybackQueue {
  const factory PlaybackQueue({
    @Default([]) List<Song> songs,
    @Default(0) int currentIndex,
    @Default(false) bool isSmartShuffleEnabled,
  }) = _PlaybackQueue;

  const PlaybackQueue._();

  Song? get currentSong => (songs.isNotEmpty && currentIndex >= 0 && currentIndex < songs.length) 
      ? songs[currentIndex] 
      : null;
}