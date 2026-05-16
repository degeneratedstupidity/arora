import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arora/data/datasources/local/hive_database.dart';
import 'package:arora/domain/entities/playlist.dart';
import 'package:arora/domain/entities/song.dart';

part 'liked_songs_service.g.dart';

const likedSongsPlaylistId = '__liked_songs__';

@Riverpod(keepAlive: true)
class LikedSongsNotifier extends _$LikedSongsNotifier {
  Box<Playlist> get _box => Hive.box<Playlist>(HiveDatabase.playlistsBoxName);

  @override
  List<Song> build() {
    final existing = _box.get(likedSongsPlaylistId);
    if (existing == null) {
      _box.put(
        likedSongsPlaylistId,
        const Playlist(
          id: likedSongsPlaylistId,
          title: 'Liked Songs',
          isEditable: false,
        ),
      );
      return const [];
    }
    return List.unmodifiable(existing.songs);
  }

  void toggle(Song song) {
    final playlist = _box.get(likedSongsPlaylistId) ??
        const Playlist(
          id: likedSongsPlaylistId,
          title: 'Liked Songs',
          isEditable: false,
        );
    final alreadyLiked = playlist.songs.any((s) => s.id == song.id);
    final updated = alreadyLiked
        ? playlist.copyWith(
            songs: playlist.songs.where((s) => s.id != song.id).toList(),
          )
        : playlist.copyWith(songs: [...playlist.songs, song]);
    _box.put(likedSongsPlaylistId, updated);
    state = List.unmodifiable(updated.songs);
  }

  bool isLiked(String songId) => state.any((s) => s.id == songId);
}
