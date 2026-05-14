import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arora/domain/entities/song.dart';

part 'album.freezed.dart';

/// Represents a music album or EP.
///
/// Albums can be fetched from remote providers or constructed locally
/// from a user playlist. The [songs] list is optional — it is only
/// populated when the full album detail is fetched via [getAlbumDetails].
@freezed
abstract class Album with _$Album {
  const factory Album({
    /// Provider-specific album identifier.
    required String id,

    /// Album title.
    required String title,

    /// Primary artist name.
    required String artistName,

    /// URL to the album cover art.
    String? thumbnailUrl,

    /// Year of release (e.g., `2024`).
    int? releaseYear,

    /// Total number of tracks, if known.
    int? trackCount,

    /// Track list — only populated after [getAlbumDetails] is called.
    @Default([]) List<Song> songs,
  }) = _Album;
}
