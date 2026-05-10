import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'package:arora/domain/entities/song.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

@freezed
@HiveType(typeId: 1, adapterName: 'PlaylistAdapter')
abstract class Playlist with _$Playlist {
  const factory Playlist({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) @Default([]) List<Song> songs,
    @HiveField(3) String? thumbnailUrl,
    
    /// Whether the user can edit this playlist (false for auto-generated like 'Favorites')
    @HiveField(4) @Default(true) bool isEditable,
  }) = _Playlist;
}