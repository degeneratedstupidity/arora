import 'package:hive_ce/hive.dart';
import 'package:arora/domain/entities/song.dart';

part 'song_model.g.dart';

/// Hive CE model for a downloaded / cached song.
///
/// ## Relationship to [Song] domain entity
/// Conversion happens at the repository boundary via [fromSong] and [toSong].
/// The UI and use-cases only ever see the immutable [Song] entity.
///
/// ## TypeId
/// Each Hive model needs a unique integer typeId.
/// SongModel = 0, PlaylistModel = 1.
@HiveType(typeId: 0)
class SongModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String artistName;

  @HiveField(3)
  String? albumName;

  @HiveField(4)
  String? thumbnailUrl;

  @HiveField(5)
  int? durationMs;

  @HiveField(6)
  late bool hasVideo;

  @HiveField(7)
  String? videoId;

  /// Absolute path to the locally downloaded audio file.
  @HiveField(8)
  late String localFilePath;

  @HiveField(9)
  String? releaseDate;

  @HiveField(10)
  late String downloadedAt;

  // ── Conversion helpers ────────────────────────────────────────────────────

  /// Creates a [SongModel] from a domain [Song] entity + local file [path].
  static SongModel fromSong(Song song, String path) => SongModel()
    ..id = song.id
    ..title = song.title
    ..artistName = song.artistName
    ..albumName = song.albumName
    ..thumbnailUrl = song.thumbnailUrl
    ..durationMs = song.durationMs
    ..hasVideo = song.hasVideo
    ..videoId = song.videoId
    ..localFilePath = path
    ..releaseDate = song.releaseDate
    ..downloadedAt = DateTime.now().toIso8601String();

  /// Converts this model back to the domain [Song] entity.
  Song toSong() => Song(
        id: id,
        title: title,
        artistName: artistName,
        albumName: albumName,
        thumbnailUrl: thumbnailUrl,
        durationMs: durationMs,
        hasVideo: hasVideo,
        videoId: videoId,
        isDownloaded: true,
        localFilePath: localFilePath,
        releaseDate: releaseDate,
      );
}
