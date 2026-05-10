import 'package:arora/core/errors/exceptions.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/enums/video_quality.dart';
import 'package:arora/domain/providers/music_provider.dart';

/// Resolves a playable music video stream URL for a given song.
///
/// This use-case guards the [MusicProvider.getMusicVideoUrl] call by
/// verifying that the song actually has a video before making the request.
final class GetVideoUrlUseCase {
  const GetVideoUrlUseCase(this._provider);

  final MusicProvider _provider;

  /// Returns a direct video stream URL for [song] at [quality].
  ///
  /// ## Guard conditions
  /// - If [song.hasVideo] is `false`, throws [VideoUnavailableException]
  ///   immediately — no network call is made.
  /// - If [MusicProvider.supportsVideo] is `false`, throws [VideoUnavailableException].
  ///
  /// The Now Playing screen should only call this after confirming the
  /// Audio/Video toggle is visible (i.e., `song.hasVideo == true`).
  Future<String> call(
    Song song, {
    VideoQuality quality = VideoQuality.p720,
  }) {
    if (!song.hasVideo || song.videoId == null) {
      throw const VideoUnavailableException(
        'This track does not have an associated music video.',
      );
    }

    if (!_provider.supportsVideo) {
      throw VideoUnavailableException(
        '${_provider.providerName} does not support music video playback.',
      );
    }

    return _provider.getMusicVideoUrl(song.videoId!, quality: quality);
  }
}
