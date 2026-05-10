import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/library/providers/library_providers.dart';
import 'package:arora/shared/providers/music_provider_provider.dart';

part 'playlist_import_service.g.dart';

@riverpod
class PlaylistImportNotifier extends _$PlaylistImportNotifier {
  @override
  AsyncValue<List<Song>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> importFromUrl(String url) async {
    state = const AsyncValue.loading();

    try {
      final playlistId = _extractYouTubePlaylistId(url);
      if (playlistId == null) {
        throw Exception(
          'Invalid YouTube Playlist URL. Please provide a valid link containing a "list=" parameter.',
        );
      }

      final musicProvider = ref.read(musicProviderProvider);

      // Our provider treats albumId as a YouTube Playlist ID internally
      final album = await musicProvider.getAlbumDetails(playlistId);

      state = AsyncValue.data(album.songs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String? _extractYouTubePlaylistId(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.queryParameters.containsKey('list')) {
      return uri.queryParameters['list'];
    }

    // Check if the user pasted the raw ID (typically starts with PL, OL, RD, etc.)
    if (url.length >= 18 && !url.contains('/')) {
      return url;
    }
    return null;
  }

  Future<void> saveToLibrary(List<Song> songs) async {
    if (songs.isEmpty) return;
    final repo = ref.read(playlistRepositoryProvider);
    final playlist = await repo.createPlaylist(
      'Imported Playlist',
      description: '${songs.length} tracks',
    );
    for (final song in songs) {
      await repo.addSongToPlaylist(playlist.id, song);
    }
    // Refresh the library list and reset import state.
    ref.invalidate(playlistsProvider);
    state = const AsyncValue.data([]);
  }
}
