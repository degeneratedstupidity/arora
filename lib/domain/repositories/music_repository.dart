import 'package:arora/domain/entities/album.dart';
import 'package:arora/domain/entities/lyrics.dart';
import 'package:arora/domain/entities/playlist.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/enums/audio_quality.dart';
import 'package:arora/domain/enums/video_quality.dart';

/// Interface for remote music data access.
///
/// The [MusicRepositoryImpl] composes a [MusicProvider] with local caching
/// (Isar) to provide an offline-first data strategy.
abstract class MusicRepository {
  /// Searches for songs — returns cached results when offline.
  Future<List<Song>> searchSongs(String query, {int limit = 20, int page = 0});

  /// Searches for albums.
  Future<List<Album>> searchAlbums(String query, {int limit = 20, int page = 0});

  /// Returns a cached-or-fresh audio stream URL for [songId].
  Future<String> getStreamUrl(String songId, {AudioQuality quality = AudioQuality.high});

  /// Returns a music video stream URL for [songId].
  Future<String> getMusicVideoUrl(String songId, {VideoQuality quality = VideoQuality.p720});

  /// Full song metadata.
  Future<Song> getSongDetails(String songId);

  /// Full album metadata with track list.
  Future<Album> getAlbumDetails(String albumId);

  /// Fetches lyrics, returning null if unavailable.
  Future<Lyrics?> getLyrics(String songId);

  /// Returns song recommendations for Smart Shuffle.
  Future<List<Song>> getRecommendations(String songId, {int limit = 20});

  /// Returns trending songs.
  Future<List<Song>> getTrending({String? countryCode, int limit = 20});
}

/// Interface for local playlist CRUD operations.
///
/// All reads and writes go directly to the Isar local database.
abstract class PlaylistRepository {
  /// Returns all user-created playlists ordered by [Playlist.updatedAt] descending.
  Future<List<Playlist>> getAllPlaylists();

  /// Returns the playlist with [id], or null if not found.
  Future<Playlist?> getPlaylistById(String id);

  /// Creates a new playlist and returns it with its assigned [id].
  Future<Playlist> createPlaylist(String name, {String? description});

  /// Updates the name and/or description of an existing playlist.
  Future<Playlist> updatePlaylistDetails(
    String id, {
    String? name,
    String? description,
  });

  /// Appends [song] to the end of playlist [playlistId].
  Future<void> addSongToPlaylist(String playlistId, Song song);

  /// Removes [song] from playlist [playlistId] (by song ID match).
  Future<void> removeSongFromPlaylist(String playlistId, String songId);

  /// Reorders songs within a playlist by providing the new ordered [songIds].
  Future<void> reorderPlaylist(String playlistId, List<String> songIds);

  /// Permanently deletes a playlist and its song references.
  Future<void> deletePlaylist(String id);
}
