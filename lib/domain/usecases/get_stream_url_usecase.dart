import 'package:arora/domain/enums/audio_quality.dart';
import 'package:arora/domain/providers/music_provider.dart';

/// Resolves a playable audio stream URL for a given song.
///
/// This use-case acts as the gateway between [AudioPlayerService] and the
/// active [MusicProvider]. It is responsible for quality selection logic.
final class GetStreamUrlUseCase {
  const GetStreamUrlUseCase(this._provider);

  final MusicProvider _provider;

  /// Returns a direct audio stream URL for [songId] at [quality].
  ///
  /// Throws [StreamUnavailableException] if no stream can be resolved.
  Future<String> call(
    String songId, {
    AudioQuality quality = AudioQuality.high,
  }) =>
      _provider.getStreamUrl(songId, quality: quality);
}
