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

class AudioPlayerService {
  AudioPlayerService({
    required Ref ref,
    required GetStreamUrlUseCase getStreamUrl,
    this.onMediaChanged,
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

  /// Fires on song change and play/pause toggle — wired to aroraAudioHandler to
  /// keep lock screen in sync without a circular import of AudioServiceHandler.
  final void Function()? onMediaChanged;

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
  bool _isLoading = false;
  final Map<String, Future<String>> _pendingUrlFetches = {};

  // Seed rotation for skipNext() recommendations — each skip uses a different
  // Radio Mix seed so the resulting pool is genuinely varied.
  final List<Song> _skipSeeds = [];
  int _skipSeedIndex = 0;

  // Cross-skip dedup: songs heard earlier this session don't resurface.
  final Set<String> _heardIds = {};
  final List<String> _heardIdQueue = [];
  static const _maxSkipSeeds = 8;
  static const _maxHeardIds = 100;

  // Completion ratio of the song that just finished — captured before
  // _player.stop() resets the position. Read by SmartShuffleService for
  // genre preference feedback.
  double _lastCompletionRatio = 0.0;
  String? _lastCompletedSongId;

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
  double get lastCompletionRatio => _lastCompletionRatio;
  String? get lastCompletedSongId => _lastCompletedSongId;
  bool get isPlaying => _player.playing;
  bool get isLoading => _isLoading;
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

  Future<void> play(Song song, {AudioQuality? quality}) async {
    if (quality != null) _quality = quality;
    _ref.read(playbackQueueProvider.notifier).playSong(song);
  }

  void _recordSongForSkip(Song song) {
    _addHeardId(song.id);
    _skipSeeds.removeWhere((s) => s.id == song.id);
    _skipSeeds.insert(0, song);
    if (_skipSeeds.length > _maxSkipSeeds) _skipSeeds.removeLast();
  }

  void _addHeardId(String songId) {
    if (_heardIds.contains(songId)) return;
    _heardIds.add(songId);
    _heardIdQueue.add(songId);
    if (_heardIdQueue.length > _maxHeardIds) {
      _heardIds.remove(_heardIdQueue.removeAt(0));
    }
  }

  Future<void> _loadAndPlaySong(Song song) async {
    _isLoading = true;
    _isLoadingController.add(true);

    // Capture completion ratio before _player.stop() resets position to 0.
    if (_currentSong != null && _currentSong!.id != song.id) {
      final pos = _player.position.inMilliseconds;
      final dur = _player.duration?.inMilliseconds ?? 0;
      _lastCompletionRatio = dur > 0 ? pos / dur : 0.0;
      _lastCompletedSongId = _currentSong!.id;
      _recordSongForSkip(_currentSong!);
    }

    // Emit the song immediately so the player screen renders before URL fetch.
    _currentSong = song;
    _currentSongController.add(song);
    // Notify the media session of the new track (artwork + title on lock screen).
    onMediaChanged?.call();

    try {
      _log.info('play: ${song.title} by ${song.artistName}');

      // Start URL resolution and stop() in parallel:
      // - stop() silences the old song immediately (ghost playback fix)
      // - URL fetch starts concurrently so we don't waste the stop() time
      final urlFuture = _resolveUrl(song);
      await _player.stop();        // waits for old audio to silence
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
      _isLoading = false;
      _isLoadingController.add(false);
    }
  }

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

  // Single-song queue: grows the queue before advancing because next() on
  // index 0 of length 1 produces identical Riverpod state — listener never fires.
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

      // Rotate through recently played songs as seeds so each skip produces
      // a different Radio Mix rather than always re-using the current song.
      final seedPool = _skipSeeds.isNotEmpty ? _skipSeeds : [currentSong];
      final seed = seedPool[_skipSeedIndex % seedPool.length];
      _skipSeedIndex++;

      final List<Song> recs = await musicProvider.getRecommendations(
        seed.id,
        limit: 10,
        artistHint: seed.artistName,
      );

      // Race-condition guard: abort if the user started a different song while
      // we were fetching, so we don't hijack their intentional selection.
      final latestQueue = _ref.read(playbackQueueProvider);
      if (latestQueue.currentSong?.id != currentSong.id) return;

      // Filter out songs heard earlier this session.
      final filtered =
          recs.where((s) => !_heardIds.contains(s.id)).toList();
      final toAdd = filtered.isNotEmpty ? filtered : recs;

      if (toAdd.isNotEmpty) {
        _ref.read(playbackQueueProvider.notifier).addAllLast(toAdd);
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

  // Concurrent callers for the same song.id share one in-flight fetch —
  // prevents duplicate YouTube API calls when pre-fetch and playback race.
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
    // Forward playing state to UI stream and keep notification in sync.
    _player.playingStream.listen((playing) {
      _isPlayingController.add(playing);
      onMediaChanged?.call();
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
