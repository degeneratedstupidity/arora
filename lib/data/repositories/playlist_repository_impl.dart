import 'package:arora/core/errors/exceptions.dart';
import 'package:arora/core/utils/logger.dart';
import 'package:arora/data/datasources/local/hive_database.dart';
import 'package:arora/domain/entities/playlist.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/repositories/music_repository.dart';
import 'package:hive_ce/hive.dart';

/// Hive CE-backed implementation of [PlaylistRepository].
///
/// Uses [HiveDatabase.playlistsBoxName] (Box<Playlist>) opened during app init.
/// Songs are embedded directly in the Playlist entity — no secondary lookup needed.
class PlaylistRepositoryImpl implements PlaylistRepository {
  static const _log = AroraLogger('PlaylistRepositoryImpl');

  Box<Playlist> get _box => Hive.box<Playlist>(HiveDatabase.playlistsBoxName);

  // ── Read ──────────────────────────────────────────────────────────────────

  @override
  Future<List<Playlist>> getAllPlaylists() async {
    try {
      return _box.values.toList();
    } catch (e) {
      _log.error('getAllPlaylists failed', error: e);
      throw DatabaseException('Failed to load playlists: $e');
    }
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      _log.error('getPlaylistById failed for $id', error: e);
      throw DatabaseException('Failed to load playlist $id: $e');
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────

  @override
  Future<Playlist> createPlaylist(String name, {String? description}) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final playlist = Playlist(id: id, title: name);
      await _box.put(id, playlist);
      _log.info('Created playlist: $name ($id)');
      return playlist;
    } catch (e) {
      _log.error('createPlaylist failed', error: e);
      throw DatabaseException('Failed to create playlist: $e');
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  @override
  Future<Playlist> updatePlaylistDetails(
    String id, {
    String? name,
    String? description,
  }) async {
    try {
      var playlist =
          _box.get(id) ?? (throw NotFoundException('Playlist $id not found.'));
      if (name != null) playlist = playlist.copyWith(title: name);
      await _box.put(id, playlist);
      return playlist;
    } catch (e) {
      _log.error('updatePlaylistDetails failed for $id', error: e);
      throw DatabaseException('Failed to update playlist: $e');
    }
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    try {
      final playlist = _box.get(playlistId) ??
          (throw NotFoundException('Playlist $playlistId not found.'));
      if (playlist.songs.any((s) => s.id == song.id)) return;
      await _box.put(
        playlistId,
        playlist.copyWith(songs: [...playlist.songs, song]),
      );
      _log.info('Added "${song.title}" to playlist ${playlist.title}');
    } catch (e) {
      _log.error('addSongToPlaylist failed', error: e);
      throw DatabaseException('Failed to add song to playlist: $e');
    }
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final playlist = _box.get(playlistId) ??
          (throw NotFoundException('Playlist $playlistId not found.'));
      await _box.put(
        playlistId,
        playlist.copyWith(
          songs: playlist.songs.where((s) => s.id != songId).toList(),
        ),
      );
    } catch (e) {
      _log.error('removeSongFromPlaylist failed', error: e);
      throw DatabaseException('Failed to remove song: $e');
    }
  }

  @override
  Future<void> reorderPlaylist(String playlistId, List<String> songIds) async {
    try {
      final playlist = _box.get(playlistId) ??
          (throw NotFoundException('Playlist $playlistId not found.'));
      final songMap = {for (final s in playlist.songs) s.id: s};
      final reordered =
          songIds.map((id) => songMap[id]).whereType<Song>().toList();
      await _box.put(playlistId, playlist.copyWith(songs: reordered));
    } catch (e) {
      _log.error('reorderPlaylist failed', error: e);
      throw DatabaseException('Failed to reorder playlist: $e');
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  @override
  Future<void> deletePlaylist(String id) async {
    try {
      await _box.delete(id);
      _log.info('Deleted playlist $id');
    } catch (e) {
      _log.error('deletePlaylist failed for $id', error: e);
      throw DatabaseException('Failed to delete playlist: $e');
    }
  }
}
