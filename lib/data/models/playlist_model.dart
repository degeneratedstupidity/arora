import 'package:hive_ce/hive.dart';
import 'package:arora/domain/entities/playlist.dart';
import 'package:arora/domain/entities/song.dart';

part 'playlist_model.g.dart';

/// Hive CE model for a user-created local playlist.
///
/// ## Song storage strategy
/// Only song IDs are stored (not embedded [SongModel] objects).
/// The repository resolves each ID against the `songs` Hive box when the
/// full playlist with tracks is needed. This avoids data duplication and
/// keeps the model schema simple.
///
/// ## TypeId
/// SongModel = 0, PlaylistModel = 1.
@HiveType(typeId: 1)
class PlaylistModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? description;

  /// Ordered list of song IDs in this playlist.
  @HiveField(3)
  late List<String> songIds;

  @HiveField(4)
  late String createdAt;

  @HiveField(5)
  late String updatedAt;

  // ── Conversion helpers ────────────────────────────────────────────────────

  /// Creates a new [PlaylistModel] ready to be saved.
  static PlaylistModel create({
    required String name,
    String? description,
  }) =>
      PlaylistModel()
        ..id = DateTime.now().millisecondsSinceEpoch.toString()
        ..name = name
        ..description = description
        ..songIds = []
        ..createdAt = DateTime.now().toIso8601String()
        ..updatedAt = DateTime.now().toIso8601String();

  /// Converts to the domain [Playlist] entity (songs list is filled by repo).
  Playlist toPlaylist({List<Song>? songs}) => Playlist(
        id: id,
        title: name,
        songs: songs ?? const <Song>[],
      );
}
