import 'package:audio_service/audio_service.dart';
import 'package:arora/core/utils/logger.dart';
import 'package:arora/services/audio/audio_player_service.dart';

/// {@template audio_service_handler}
/// Bridges [AudioPlayerService] with the `audio_service` plugin.
///
/// ## What this enables
/// By implementing [BaseAudioHandler], Arora gets:
/// - **Lock screen controls** on iOS and Android (play/pause/skip/seek)
/// - **Media notification** with album art and progress bar
/// - **Hardware media button** support (headphones, car Bluetooth)
/// - **MPRIS integration** on Linux (media controls in desktop DEs)
/// - **macOS Now Playing** widget
/// - **Background playback** that survives the app being backgrounded
///
/// ## Integration
/// Registered via [AudioService.init] in `lib/main.dart` during app startup.
/// `audio_service` manages the native media session lifecycle.
///
/// ## Why this is a separate class
/// `audio_service` requires its own `BaseAudioHandler` subclass to run
/// in an isolate-safe context. Keeping it separate from [AudioPlayerService]
/// maintains the single-responsibility principle.
/// {@endtemplate}
class AudioServiceHandler extends BaseAudioHandler with SeekHandler {
  AudioServiceHandler(this._audioService);

  final AudioPlayerService _audioService;
  static const _log = AroraLogger('AudioServiceHandler');

  // ── BaseAudioHandler overrides ────────────────────────────────────────────

  @override
  Future<void> play() async {
    _log.debug('play (from media button / lock screen)');
    await _audioService.resume();
    await _broadcastState();
  }

  @override
  Future<void> pause() async {
    _log.debug('pause (from media button / lock screen)');
    await _audioService.pause();
    await _broadcastState();
  }

  @override
  Future<void> stop() async {
    _log.debug('stop');
    await _audioService.pause();
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ),);
  }

  @override
  Future<void> skipToNext() async {
    _log.debug('skipToNext (from lock screen)');
    await _audioService.skipNext();
    _updateMediaItem();
    await _broadcastState();
  }

  @override
  Future<void> skipToPrevious() async {
    _log.debug('skipToPrevious (from lock screen)');
    await _audioService.skipPrevious();
    _updateMediaItem();
    await _broadcastState();
  }

  @override
  Future<void> seek(Duration position) async {
    _log.debug('seek: ${position.inSeconds}s (from lock screen)');
    await _audioService.seek(position);
    await _broadcastState();
  }

  @override
  Future<void> fastForward() async {
    await _audioService.seekForward();
    await _broadcastState();
  }

  @override
  Future<void> rewind() async {
    await _audioService.seekBackward();
    await _broadcastState();
  }

  // ── State broadcasting ────────────────────────────────────────────────────

  /// Pushes the current [AudioPlayerService] state to `audio_service`.
  ///
  /// Must be called after every state-changing action so the lock screen
  /// and notification remain in sync with actual playback.
  Future<void> _broadcastState() async {
    final isPlaying = _audioService.isPlaying;
    final position = _audioService.position;
    final duration = _audioService.duration;

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.rewind,
          MediaControl.skipToPrevious,
          isPlaying ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.fastForward,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [1, 2, 3],
        processingState: isPlaying
            ? AudioProcessingState.ready
            : AudioProcessingState.idle,
        playing: isPlaying,
        updatePosition: position,
        bufferedPosition: duration ?? Duration.zero,
        speed: 1.0,
      ),
    );
  }

  /// Updates the [MediaItem] (track metadata) on the lock screen / notification.
  void _updateMediaItem() {
    final item = _audioService.currentMediaItem;
    if (item != null) {
      mediaItem.add(item);
    }
  }

  /// Call this whenever the current song changes.
  ///
  /// Broadcasts the updated [MediaItem] to the system media session.
  void onSongChanged() {
    _updateMediaItem();
    _broadcastState();
  }
}
