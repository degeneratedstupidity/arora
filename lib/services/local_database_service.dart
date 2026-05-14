import 'package:arora/data/datasources/local/hive_database.dart';
import 'package:arora/domain/entities/playlist.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_database_service.g.dart';

@Riverpod(keepAlive: true)
LocalDatabaseService localDatabaseService(Ref ref) {
  return LocalDatabaseService();
}

class LocalDatabaseService {
  final Box<Playlist> _playlistsBox = Hive.box<Playlist>(HiveDatabase.playlistsBoxName);
  final Box<Song> _downloadsBox = Hive.box<Song>(HiveDatabase.downloadsBoxName);

  // --- Playlists ---
  
  List<Playlist> getAllPlaylists() => _playlistsBox.values.toList();

  Future<void> createPlaylist(String title) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final playlist = Playlist(id: id, title: title);
    await _playlistsBox.put(id, playlist);
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    await _playlistsBox.put(playlist.id, playlist);
  }

  Future<void> deletePlaylist(String id) async {
    await _playlistsBox.delete(id);
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final playlist = _playlistsBox.get(playlistId);
    if (playlist != null) {
      if (playlist.songs.any((s) => s.id == song.id)) return; // Prevent duplicates
      final updatedSongs = List<Song>.from(playlist.songs)..add(song);
      await _playlistsBox.put(playlistId, playlist.copyWith(songs: updatedSongs));
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = _playlistsBox.get(playlistId);
    if (playlist != null) {
      final updatedSongs = playlist.songs.where((s) => s.id != songId).toList();
      await _playlistsBox.put(playlistId, playlist.copyWith(songs: updatedSongs));
    }
  }

  // --- Downloads ---

  List<Song> getAllDownloads() => _downloadsBox.values.toList();

  Song? getDownloadedSong(String id) => _downloadsBox.get(id);

  Future<void> saveDownloadedSong(Song song) async {
    await _downloadsBox.put(song.id, song);
  }

  Future<void> removeDownloadedSong(String id) async {
    await _downloadsBox.delete(id);
  }
}