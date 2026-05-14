import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/data/repositories/playlist_repository_impl.dart';
import 'package:arora/domain/entities/playlist.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/repositories/music_repository.dart';

/// The playlist repository — backed by Isar.
final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepositoryImpl();
});

/// All user playlists, sorted by last modified.
final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.getAllPlaylists();
});

/// A single playlist with its full song list.
final playlistDetailProvider =
    FutureProvider.family<Playlist?, String>((ref, id) async {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.getPlaylistById(id);
});

// ---------------------------------------------------------------------------
// Playlist mutation notifier
// ---------------------------------------------------------------------------

/// Manages playlist mutation operations (create, add song, delete).
///
/// After any mutation, invalidates [playlistsProvider] so the list rebuilds.
class PlaylistNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(String name, {String? description}) async {
    final repo = ref.read(playlistRepositoryProvider);
    await repo.createPlaylist(name, description: description);
    ref.invalidate(playlistsProvider);
  }

  Future<void> addSong(String playlistId, Song song) async {
    final repo = ref.read(playlistRepositoryProvider);
    await repo.addSongToPlaylist(playlistId, song);
    ref.invalidate(playlistDetailProvider(playlistId));
    ref.invalidate(playlistsProvider);
  }

  Future<void> removeSong(String playlistId, String songId) async {
    final repo = ref.read(playlistRepositoryProvider);
    await repo.removeSongFromPlaylist(playlistId, songId);
    ref.invalidate(playlistDetailProvider(playlistId));
    ref.invalidate(playlistsProvider);
  }

  Future<void> delete(String playlistId) async {
    final repo = ref.read(playlistRepositoryProvider);
    await repo.deletePlaylist(playlistId);
    ref.invalidate(playlistsProvider);
  }

  Future<void> reorder(String playlistId, List<String> songIds) async {
    final repo = ref.read(playlistRepositoryProvider);
    await repo.reorderPlaylist(playlistId, songIds);
    ref.invalidate(playlistDetailProvider(playlistId));
    ref.invalidate(playlistsProvider);
  }
}

final playlistNotifierProvider =
    AsyncNotifierProvider<PlaylistNotifier, void>(PlaylistNotifier.new);
