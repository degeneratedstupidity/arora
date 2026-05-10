import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/usecases/get_stream_url_usecase.dart';
import 'package:arora/services/audio/audio_player_service.dart';
import 'package:arora/services/audio/smart_shuffle_service.dart';
import 'package:arora/services/download/download_manager.dart';
import 'package:arora/shared/providers/music_provider_provider.dart';
import 'package:just_audio/just_audio.dart';

export 'package:arora/shared/providers/music_provider_provider.dart'
    show musicProviderProvider;

// ---------------------------------------------------------------------------
// Core service providers — registered here, consumed across all features
// ---------------------------------------------------------------------------

/// The singleton [AudioPlayerService].
///
/// Riverpod keeps a single instance alive for the app's lifetime.
/// `ref.onDispose` ensures the audio player is properly released on hot-restart.
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final getStreamUrl = ref.watch(getStreamUrlUseCaseProvider);
  final service = AudioPlayerService(
    ref: ref,
    getStreamUrl: getStreamUrl,
  );
  ref.onDispose(service.dispose);
  // Eagerly initialize SmartShuffleService so its queue listener is active.
  ref.read(smartShuffleServiceProvider);
  return service;
});

/// The singleton [DownloadManager].
final downloadManagerProvider = Provider<DownloadManager>((ref) {
  final getStreamUrl = ref.watch(getStreamUrlUseCaseProvider);
  final manager = DownloadManager(getStreamUrl);
  ref.onDispose(manager.dispose);
  return manager;
});

// ---------------------------------------------------------------------------
// Use-case providers
// ---------------------------------------------------------------------------

final getStreamUrlUseCaseProvider = Provider<GetStreamUrlUseCase>((ref) {
  return GetStreamUrlUseCase(ref.watch(musicProviderProvider));
});

// ---------------------------------------------------------------------------
// Reactive state providers (consumed by UI)
// ---------------------------------------------------------------------------

/// The currently playing [Song]. Null when idle.
final currentSongProvider = StreamProvider<Song?>((ref) {
  return ref.watch(audioPlayerServiceProvider).currentSongStream;
});

/// Whether audio is currently playing.
final isPlayingProvider = StreamProvider<bool>((ref) {
  return ref.watch(audioPlayerServiceProvider).isPlayingStream;
});

/// Whether a stream URL is being resolved / buffering.
final isLoadingProvider = StreamProvider<bool>((ref) {
  return ref.watch(audioPlayerServiceProvider).isLoadingStream;
});

/// Current playback position.
final playbackPositionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerServiceProvider).positionStream;
});

/// Current `just_audio` [ProcessingState].
final processingStateProvider = StreamProvider<ProcessingState>((ref) {
  return ref.watch(audioPlayerServiceProvider).processingStateStream;
});

/// The active [LoopMode].
final loopModeProvider =
    NotifierProvider<LoopModeNotifier, LoopMode>(LoopModeNotifier.new);

class LoopModeNotifier extends Notifier<LoopMode> {
  @override
  LoopMode build() => LoopMode.off;

  void update(LoopMode mode) => state = mode;
}

/// Current volume level (0.0 to 1.0).
final volumeProvider = StreamProvider<double>((ref) {
  return ref.watch(audioPlayerServiceProvider).volumeStream;
});

/// Whether shuffle is currently enabled.
final isShuffleProvider =
    NotifierProvider<IsShuffleNotifier, bool>(IsShuffleNotifier.new);

class IsShuffleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void update(bool shuffle) => state = shuffle;
}

// ---------------------------------------------------------------------------
// Player mode (audio vs. video toggle)
// ---------------------------------------------------------------------------

/// Tracks whether the Now Playing screen is in audio or video mode.
enum PlayerMode { audio, video }

final playerModeProvider =
    NotifierProvider<PlayerModeNotifier, PlayerMode>(PlayerModeNotifier.new);

class PlayerModeNotifier extends Notifier<PlayerMode> {
  @override
  PlayerMode build() => PlayerMode.audio;

  void update(PlayerMode mode) => state = mode;
}
