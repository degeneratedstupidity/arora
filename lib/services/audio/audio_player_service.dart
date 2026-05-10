import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:arora/core/constants/app_constants.dart';
import 'package:arora/core/utils/logger.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/enums/audio_quality.dart';
import 'package:arora/domain/usecases/get_stream_url_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/services/audio/playback_queue_notifier.dart';
import 'package:arora/domain/entities/playback_queue.dart';
import 'package:arora/services/cache_service.dart';
import 'package:arora/shared/providers/music_provider_provider.dart';
import 'package:just_audio/just_audio.dart';

/// {@template audio_player_service}
/// The central audio playback service for Arora.
///
/// ## Responsibilities
/// - Wraps `just_audio`'s [AudioPlayer] with Arora's domain model.
/// - Manages the active [Song] and playback state.
/// - Integrates with [SmartShuffleEngine] for queue management.
/// - Caches stream URLs for [AppConstants.streamUrlTtl] to avoid
///   re-fetching the same URL repeatedly (YouTube URLs expire after ~6h).
/// - Exposes reactive [Stream]s for the UI layer via Riverpod.
///
/// ## Usage
/// This service is registered as a Riverpod provider in `lib/app.dart`.
/// UI widgets observe its streams via `ref.watch(...)`.
///
/// ## Background audio
/// Background audio and lock screen controls are handled by
/// [AudioServiceHandler], which wraps this service.
/// {@endtemplate}
class AudioPlayerService {
  AudioPlayerService({
    required Ref ref,
    required GetStreamUrlUseCase getStreamUrl,
  })  : _ref = ref,
        _getStreamUrl = getStreamUrl,
        _cache = ref.read(cacheServiceProvider) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    if (isAndroid) {
      _equalizer = AndroidEqualizer();
      _loudnessEnhancer = AndroidLoudnessEnhancer();
      _player = AudioPlayer(
        audioPipeline: AudioPipeline(
          androidAudioEffects: [_equalizer!, _loudnessEnhancer!],
        ),
      );
    } else {
      _equalizer = null;
      _loudnessEnhancer = null;
      _player = AudioPlayer();
    }
    _initPlayerListeners();

    // Listen to queue changes
    _ref.listen<PlaybackQueue>(playbackQueueProvider, (previous, next) {
      final previousSong = previous?.currentSong;
      final nextSong = next.currentSong;

      final songChanged = previousSong?.id != nextSong?.id;
      final indexChanged = previous?.currentIndex != next.currentIndex;

      if (nextSong != null && (songChanged || indexChanged)) {
        _loadAndPlaySong(nextSong);
      } else if (nextSong == null && previousSong != null) {
        _player.stop();
        _currentSong = null;
        _currentSongController.add(null);
      }
    });
  }

  final Ref _ref;
  late final AudioPlayer _player;
  AndroidEqualizer? _equalizer;
  AndroidLoudnessEnhancer? _loudnessEnhancer;
  final GetStreamUrlUseCase _getStreamUrl;
  final CacheService _cache;
  static const _log = AroraLogger('AudioPlayerService');

  // ── State ──────────────────────────────────────────────────────────────────

  Song? _currentSong;
  LoopMode _loopMode = LoopMode.off;
  AudioQuality _quality = AudioQuality.high;
  bool _isFetchingRecs = false;
  final Map<String, Future<String>> _pendingUrlFetches = {};

  /// StreamControllers that broadcast state changes to the UI.
  final _currentSongController = StreamController<Song?>.broadcast();
  final _isPlayingController = StreamController<bool>.broadcast();
  final _isLoadingController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // ── Public streams ────────────────────────────────────────────────────────

  /// The currently playing [Song]. Null when nothing is loaded.
  Stream<Song?> get currentSongStream => _currentSongController.stream;

  /// Emits `true` when audio is playing, `false` when paused or stopped.
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  /// Emits `true` while a stream URL is being resolved or buffering.
  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  /// Emits a user-friendly error message when playback fails.
  Stream<String> get errorStream => _errorController.stream;

  /// Current playback position stream from `just_audio`.
  Stream<Duration> get positionStream => _player.positionStream;

  /// Buffered position stream from `just_audio`.
  Stream<Duration?> get bufferedPositionStream =>
      _player.bufferedPositionStream;

  /// Current [ProcessingState] stream from `just_audio`.
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  // ── Synchronous state accessors ───────────────────────────────────────────

  Song? get currentSong => _ref.read(playbackQueueProvider).currentSong;
  bool get isPlaying => _player.playing;
  bool get isShuffleEnabled => _ref.read(playbackQueueProvider).isSmartShuffleEnabled;
  LoopMode get loopMode => _loopMode;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  AudioQuality get quality => _quality;
  AndroidEqualizer? get equalizer => _equalizer;
  AndroidLoudnessEnhancer? get loudnessEnhancer => _loudnessEnhancer;
  
  int get queueLength {
    final q = _ref.read(playbackQueueProvider);
    return q.songs.length - 1 - q.currentIndex;
  }
  
  List<Song> get upcomingQueue {
    final q = _ref.read(playbackQueueProvider);
    return q.currentIndex + 1 < q.songs.length ? q.songs.sublist(q.currentIndex + 1) : [];
  }

  // ── Playback control ──────────────────────────────────────────────────────

  /// Loads [song] and begins playback immediately.
  ///
  /// Resolves the stream URL (with cache), sets the audio source on
  /// `just_audio`, and plays. Emits loading / error states as needed.
  Future<void> play(Song song, {AudioQuality? quality}) async {
    if (quality != null) _quality = quality;
    _ref.read(playbackQueueProvider.notifier).playSong(song);
  }

  Future<void> _loadAndPlaySong(Song song) async {
    _isLoadingController.add(true);

    // Emit the song immediately so the player screen renders before URL fetch.
    _currentSong = song;
    _currentSongController.add(song);

    try {
      _log.info('play: ${song.title} by ${song.artistName}');

      // Start URL resolution and stop() in parallel:
      // - stop() silences the old song immediately (ghost playback fix)
      // - URL fetch starts concurrently so we don't waste the stop() time
      final urlFuture = _resolveUrl(song);
      await _player.stop();       // waits for old audio to silence
      final url = await urlFuture; // waits for URL (often already done)

      final AudioSource source = song.isDownloaded && song.localFilePath != null
          ? AudioSource.file(song.localFilePath!)
          : AudioSource.uri(Uri.parse(url));

      await _player.setAudioSource(source);
      await _player.play();
    } catch (e) {
      _log.error('play failed for ${song.id}', error: e);
      _errorController.add('Could not play "${song.title}". Try again.');
    } finally {
      _isLoadingController.add(false);
    }
  }

  /// Initialises a shuffle queue from [songs] and starts playback.
  ///
  /// If [startWith] is provided, that song plays first.
  Future<void> playQueue(
    List<Song> songs, {
    Song? startWith,
    bool shuffle = false,
  }) async {
    final initialIndex = startWith != null ? songs.indexWhere((s) => s.id == startWith.id) : 0;
    _ref.read(playbackQueueProvider.notifier).playPlaylist(
      songs,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
    if (shuffle && !_ref.read(playbackQueueProvider).isSmartShuffleEnabled) {
      _ref.read(playbackQueueProvider.notifier).toggleSmartShuffle();
    }
  }

  /// Pauses playback. Can be resumed with [resume].
  Future<void> pause() async {
    _log.debug('pause');
    await _player.pause();
  }

  /// Resumes a paused track.
  Future<void> resume() async {
    _log.debug('resume');
    await _player.play();
  }

  /// Toggles between play and pause.
  Future<void> togglePlayPause() async =>
      _player.playing ? pause() : resume();

  /// Skips to the next song in the queue.
  ///
  /// When the queue has more than one song, advances the index normally.
  /// When only one song is queued, uses pre-fetched recommendations (or fetches
  /// them on demand) to grow the queue before advancing — otherwise Riverpod
  /// sees identical state and the listener never fires.
  Future<void> skipNext() async {
    _log.debug('skipNext');
    final queue = _ref.read(playbackQueueProvider);

    if (queue.songs.length > 1) {
      _ref.read(playbackQueueProvider.notifier).next();
      return;
    }

    // Single-song queue: grow it before advancing.
    final currentSong = queue.currentSong;
    if (currentSong == null || _isFetchingRecs) return;

    _isFetchingRecs = true;
    _isLoadingController.add(true);
    try {
      _log.debug('skipNext: fetching recs on demand');
      final musicProvider = _ref.read(musicProviderProvider);
      final List<Song> recs = await musicProvider.getRecommendations(
        currentSong.id,
        limit: 10,
        artistHint: currentSong.artistName,
      );

      // Race-condition guard: abort if the user started a different song while
      // we were fetching, so we don't hijack their intentional selection.
      final latestQueue = _ref.read(playbackQueueProvider);
      if (latestQueue.currentSong?.id != currentSong.id) return;

      if (recs.isNotEmpty) {
        _ref.read(playbackQueueProvider.notifier).addAllLast(recs);
        // The queue listener pre-fetches the next song's URL automatically here.
      }
    } catch (_) {
      // Best-effort — silently skip if offline or API is unavailable.
    } finally {
      _isFetchingRecs = false;
      _isLoadingController.add(false);
    }

    _ref.read(playbackQueueProvider.notifier).next();
  }

  /// Restarts the current song, or skips to previous if in first 3 seconds.
  Future<void> skipPrevious() async {
    _log.debug('skipPrevious');
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else {
      _ref.read(playbackQueueProvider.notifier).previous();
    }
  }

  /// Volume stream from `just_audio` (0.0 to 1.0).
  Stream<double> get volumeStream => _player.volumeStream;

  /// Current volume level (0.0 to 1.0).
  double get volume => _player.volume;

  /// Sets the playback volume. [volume] must be between 0.0 and 1.0.
  Future<void> setVolume(double volume) => _player.setVolume(volume.clamp(0.0, 1.0));

  /// Seeks to [position] in the current track.
  Future<void> seek(Duration position) async {
    _log.debug('seek: ${position.inSeconds}s');
    await _player.seek(position);
  }

  /// Seeks forward by [AppConstants.seekForwardMs] milliseconds.
  Future<void> seekForward() async =>
      seek(position + const Duration(milliseconds: AppConstants.seekForwardMs));

  /// Seeks backward by [AppConstants.seekBackwardMs] milliseconds.
  Future<void> seekBackward() async {
    final target = position - const Duration(milliseconds: AppConstants.seekBackwardMs);
    await seek(target.isNegative ? Duration.zero : target);
  }

  /// Toggles shuffle mode on/off for the current queue.
  void toggleShuffle() {
    _ref.read(playbackQueueProvider.notifier).toggleSmartShuffle();
  }

  /// Cycles through loop modes: off → loopOne → loopAll → off.
  Future<void> cycleLoopMode() async {
    _loopMode = switch (_loopMode) {
      LoopMode.off => LoopMode.one,
      LoopMode.one => LoopMode.all,
      LoopMode.all => LoopMode.off,
    };
    await _player.setLoopMode(_loopMode);
    _log.info('loopMode: $_loopMode');
  }

  /// Sets the preferred [AudioQuality] for future stream URL resolutions.
  void setQuality(AudioQuality quality) {
    _quality = quality;
    _log.info('quality preference: $quality');
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Returns a cached stream URL for [song], or fetches a fresh one.
  ///
  /// Concurrent callers for the same [song.id] share the in-flight request
  /// so we never hit the YouTube API twice for the same track simultaneously
  /// (e.g. pre-fetch and actual playback racing each other).
  Future<String> _resolveUrl(Song song) async {
    if (song.isDownloaded && song.localFilePath != null) {
      return song.localFilePath!;
    }

    final cached = _cache.getStreamUrl(song.id);
    if (cached != null) {
      _log.debug('_resolveUrl: cache hit for ${song.id}');
      return cached;
    }

    if (_pendingUrlFetches.containsKey(song.id)) {
      _log.debug('_resolveUrl: joining in-flight fetch for ${song.id}');
      return _pendingUrlFetches[song.id]!;
    }

    _log.debug('_resolveUrl: fetching fresh URL for ${song.id}');
    final future = _fetchAndCacheUrl(song.id);
    _pendingUrlFetches[song.id] = future;
    return future;
  }

  Future<String> _fetchAndCacheUrl(String songId) async {
    try {
      final url = await _getStreamUrl(songId, quality: _quality);
      _cache.saveStreamUrl(songId, url);
      return url;
    } finally {
      // Map.remove returns the stored Future; we discard it intentionally.
      // ignore: unawaited_futures
      _pendingUrlFetches.remove(songId);
    }
  }

  /// Sets up listeners on `just_audio` player state.
  void _initPlayerListeners() {
    // Forward playing state to UI stream.
    _player.playingStream.listen((playing) {
      _isPlayingController.add(playing);
    });

    // Auto-advance to the next song when the current one finishes.
    _player.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        _log.debug('Track completed — advancing queue');
        await skipNext();
      }
    });
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Creates a [MediaItem] for the current song (used by [AudioServiceHandler]).
  MediaItem? get currentMediaItem {
    final song = _currentSong;
    if (song == null) return null;
    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artistName,
      album: song.albumName,
      artUri: song.thumbnailUrl != null ? Uri.parse(song.thumbnailUrl!) : null,
      duration: song.durationMs != null
          ? Duration(milliseconds: song.durationMs!)
          : null,
    );
  }

  /// Releases all resources. Called by Riverpod's `ref.onDispose`.
  Future<void> dispose() async {
    await _player.dispose();
    await _currentSongController.close();
    await _isPlayingController.close();
    await _isLoadingController.close();
    await _errorController.close();
    _log.info('AudioPlayerService disposed.');
  }
}
