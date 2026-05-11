import 'package:audio_service/audio_service.dart';
import 'package:arora/core/utils/logger.dart';

/// Global singleton registered with [AudioService.init] at startup.
///
/// [AudioPlayerService] is wired in after Riverpod initialises by calling
/// [aroraAudioHandler.connect]. This breaks the circular import that would
/// occur if [AudioPlayerService] imported this file directly.
final aroraAudioHandler = AudioServiceHandler();

/// Bridges Arora's audio engine with the `audio_service` plugin.
///
/// Registers media controls on the Android notification, lock screen,
/// Bluetooth headsets, and MPRIS (Linux). All playback commands are
/// forwarded to [AudioPlayerService] via the [_onPlay], [_onPause], etc.
/// callbacks set by [connect].
///
/// ## Why callbacks instead of a direct reference
/// [AudioPlayerService] lives inside Riverpod and is created after
/// [AudioService.init]. Storing callbacks (plain Dart closures) instead of
/// a typed reference avoids a circular import between the two files.
class AudioServiceHandler extends BaseAudioHandler with SeekHandler {
  static const _log = AroraLogger('AudioServiceHandler');

  // Callbacks wired up by player_providers.dart after Riverpod initialises.
  Future<void> Function()? _onPlay;
  Future<void> Function()? _onPause;
  Future<void> Function()? _onSkipNext;
  Future<void> Function()? _onSkipPrevious;
  Future<void> Function(Duration)? _onSeek;
  Future<void> Function()? _onFastForward;
  Future<void> Function()? _onRewind;
  bool Function()? _getIsPlaying;
  bool Function()? _getIsLoading;
  Duration Function()? _getPosition;
  Duration? Function()? _getDuration;
  MediaItem? Function()? _getMediaItem;

  /// Wire up the audio engine after Riverpod creates [AudioPlayerService].
  ///
  /// Called once from [audioPlayerServiceProvider] in player_providers.dart.
  void connect({
    required Future<void> Function() onPlay,
    required Future<void> Function() onPause,
    required Future<void> Function() onSkipNext,
    required Future<void> Function() onSkipPrevious,
    required Future<void> Function(Duration) onSeek,
    required Future<void> Function() onFastForward,
    required Future<void> Function() onRewind,
    required bool Function() getIsPlaying,
    required bool Function() getIsLoading,
    required Duration Function() getPosition,
    required Duration? Function() getDuration,
    required MediaItem? Function() getMediaItem,
  }) {
    _onPlay = onPlay;
    _onPause = onPause;
    _onSkipNext = onSkipNext;
    _onSkipPrevious = onSkipPrevious;
    _onSeek = onSeek;
    _onFastForward = onFastForward;
    _onRewind = onRewind;
    _getIsPlaying = getIsPlaying;
    _getIsLoading = getIsLoading;
    _getPosition = getPosition;
    _getDuration = getDuration;
    _getMediaItem = getMediaItem;
    _log.debug('connect: audio engine wired to media session');
  }

  // ── BaseAudioHandler overrides ────────────────────────────────────────────

  @override
  Future<void> play() async {
    _log.debug('play (lock screen / headset)');
    await _onPlay?.call();
    await broadcastState();
  }

  @override
  Future<void> pause() async {
    _log.debug('pause (lock screen / headset)');
    await _onPause?.call();
    await broadcastState();
  }

  @override
  Future<void> stop() async {
    _log.debug('stop');
    await _onPause?.call();
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ),);
  }

  @override
  Future<void> skipToNext() async {
    _log.debug('skipToNext (lock screen)');
    await _onSkipNext?.call();
    _updateMediaItem();
    await broadcastState();
  }

  @override
  Future<void> skipToPrevious() async {
    _log.debug('skipToPrevious (lock screen)');
    await _onSkipPrevious?.call();
    _updateMediaItem();
    await broadcastState();
  }

  @override
  Future<void> seek(Duration position) async {
    _log.debug('seek: ${position.inSeconds}s');
    await _onSeek?.call(position);
    await broadcastState();
  }

  @override
  Future<void> fastForward() async {
    await _onFastForward?.call();
    await broadcastState();
  }

  @override
  Future<void> rewind() async {
    await _onRewind?.call();
    await broadcastState();
  }

  // ── State broadcasting ────────────────────────────────────────────────────

  /// Pushes current playback state to the system media session.
  ///
  /// Called by [AudioPlayerService] (via the [onMediaChanged] callback)
  /// whenever song or play/pause state changes so the notification and
  /// lock screen stay in sync.
  Future<void> broadcastState() async {
    final isPlaying = _getIsPlaying?.call() ?? false;
    final isLoading = _getIsLoading?.call() ?? false;
    final position = _getPosition?.call() ?? Duration.zero;
    final duration = _getDuration?.call();

    final processingState = isLoading
        ? AudioProcessingState.loading
        : isPlaying
            ? AudioProcessingState.ready
            : AudioProcessingState.idle;

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          isPlaying ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState,
        playing: isPlaying,
        updatePosition: position,
        bufferedPosition: duration ?? Duration.zero,
        speed: 1.0,
      ),
    );
  }

  /// Pushes updated [MediaItem] (title, artist, artwork) to the session.
  void _updateMediaItem() {
    final item = _getMediaItem?.call();
    if (item != null) {
      mediaItem.add(item);
    }
  }

  /// Called whenever the current song changes.
  ///
  /// Updates both the [MediaItem] (artwork / title) and the [PlaybackState]
  /// so the notification and lock screen reflect the new track immediately.
  void onSongChanged() {
    _updateMediaItem();
    broadcastState();
  }
}
