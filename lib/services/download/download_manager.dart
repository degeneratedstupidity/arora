import 'dart:async';
import 'dart:io';

import 'package:arora/core/constants/app_constants.dart';
import 'package:arora/core/errors/exceptions.dart';
import 'package:arora/core/utils/logger.dart';
import 'package:arora/data/datasources/local/hive_database.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/enums/audio_quality.dart';
import 'package:arora/domain/usecases/get_stream_url_usecase.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

/// Represents the progress of an in-flight download.
class DownloadProgress {
  const DownloadProgress({
    required this.songId,
    required this.progress, // 0.0 → 1.0
    this.isComplete = false,
    this.error,
  });

  final String songId;
  final double progress;
  final bool isComplete;
  final String? error;
}

/// {@template download_manager}
/// Manages downloading audio files for offline playback.
///
/// ## Flow
/// 1. Calls [GetStreamUrlUseCase] to get the best audio URL.
/// 2. Downloads the file to `{documentsDir}/arora_downloads/{id}.audio`
///    using `Dio` with progress tracking.
/// 3. Persists the updated [Song] entity (with `isDownloaded: true`) in the
///    Hive `downloadsBox` (`Box<Song>`).
/// 4. Emits [DownloadProgress] events so the UI can show a progress indicator.
///
/// ## Concurrent downloads
/// Multiple songs can be downloaded simultaneously. Each active download
/// has its own `CancelToken` for individual cancellation.
/// {@endtemplate}
class DownloadManager {
  DownloadManager(this._getStreamUrl)
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(minutes: 30),
            followRedirects: true,
            maxRedirects: 10,
            // YouTube CDN requires a browser-like User-Agent and the Origin/Referer
            // headers; without them the stream URL returns 403 or serves 0 bytes.
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 '
                  '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
              'Accept': '*/*',
              'Accept-Encoding': 'identity',
              'Origin': 'https://www.youtube.com',
              'Referer': 'https://www.youtube.com/',
            },
          ),
        );

  final GetStreamUrlUseCase _getStreamUrl;
  final Dio _dio;
  static const _log = AroraLogger('DownloadManager');

  /// Active downloads keyed by song ID.
  final Map<String, CancelToken> _activeDownloads = {};

  /// Stream of [DownloadProgress] events for all active downloads.
  ///
  /// UI widgets can listen to this to show per-song progress indicators.
  final _progressController = StreamController<DownloadProgress>.broadcast();
  Stream<DownloadProgress> get progressStream => _progressController.stream;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns true if [songId] is currently being downloaded.
  bool isDownloading(String songId) => _activeDownloads.containsKey(songId);

  /// Downloads [song] for offline playback.
  ///
  /// Emits [DownloadProgress] events during the download. On completion,
  /// the song is persisted in the Hive `downloadsBox` and can be played
  /// offline via [AudioPlayerService] (which checks [Song.isDownloaded]).
  ///
  /// Does nothing if [song.isDownloaded] is already true.
  Future<void> download(Song song) async {
    if (song.isDownloaded) {
      _log.debug('download: ${song.id} already downloaded — skip');
      return;
    }

    if (_activeDownloads.containsKey(song.id)) {
      _log.debug('download: ${song.id} already in progress — skip');
      return;
    }

    _log.info('Starting download: ${song.title}');

    final cancelToken = CancelToken();
    _activeDownloads[song.id] = cancelToken;

    try {
      // 1. Resolve audio URL (high quality for downloads).
      final url = await _getStreamUrl(song.id, quality: AudioQuality.high);

      // 2. Prepare download directory.
      final dir = await _downloadsDirectory();
      // Use .audio extension — container varies (may be opus/aac/m4a).
      final filePath = '${dir.path}/${song.id}.audio';

      // 3. Download with progress.
      // YouTube often serves audio streams without a Content-Length header
      // (chunked transfer encoding). When total == -1, emit a small synthetic
      // progress so the UI stays responsive instead of appearing frozen.
      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          final progress = total > 0
              ? (received / total).clamp(0.0, 1.0)
              : (received / (received + 1024 * 512)).clamp(0.0, 0.9);
          _progressController
              .add(DownloadProgress(songId: song.id, progress: progress));
        },
      );

      // 4. Persist the downloaded song to Hive.
      await _persistDownload(song, filePath);

      _progressController.add(
        DownloadProgress(
          songId: song.id,
          progress: 1.0,
          isComplete: true,
        ),
      );

      _log.info('Download complete: ${song.title} → $filePath');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _log.info('Download cancelled: ${song.id}');
      } else {
        _log.error('Download failed for ${song.id}', error: e);
        _progressController.add(
          DownloadProgress(
            songId: song.id,
            progress: 0,
            error: 'Download failed: ${e.message}',
          ),
        );
      }
    } catch (e) {
      _log.error('Download unexpected error for ${song.id}', error: e);
      _progressController.add(
        DownloadProgress(
          songId: song.id,
          progress: 0,
          error: 'Download failed: $e',
        ),
      );
    } finally {
      _activeDownloads.remove(song.id);
    }
  }

  /// Cancels an in-progress download for [songId].
  void cancel(String songId) {
    _activeDownloads[songId]?.cancel('User cancelled download');
    _activeDownloads.remove(songId);
  }

  /// Deletes the local audio file for [song] and removes it from the downloads box.
  Future<void> deleteDownload(Song song) async {
    try {
      if (song.localFilePath != null) {
        final file = File(song.localFilePath!);
        if (await file.exists()) await file.delete();
      }

      await Hive.box<Song>(HiveDatabase.downloadsBoxName).delete(song.id);
      _log.info('Deleted download: ${song.title}');
    } catch (e) {
      _log.error('deleteDownload failed for ${song.id}', error: e);
      throw DownloadException('Failed to delete download: $e');
    }
  }

  /// Returns all downloaded songs from the Hive downloads box.
  Future<List<Song>> getDownloadedSongs() async {
    return Hive.box<Song>(HiveDatabase.downloadsBoxName).values.toList();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<Directory> _downloadsDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/${AppConstants.downloadsDirName}');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _persistDownload(Song song, String filePath) async {
    final downloadedSong = song.copyWith(
      isDownloaded: true,
      localFilePath: filePath,
    );
    await Hive.box<Song>(HiveDatabase.downloadsBoxName)
        .put(song.id, downloadedSong);
  }

  Future<void> dispose() async {
    _dio.close();
    await _progressController.close();
  }
}
