import 'package:flutter_test/flutter_test.dart';
import 'package:arora/data/datasources/local/hive_database.dart';
import 'package:arora/data/repositories/playlist_repository_impl.dart';
import 'package:arora/domain/entities/song.dart';

void main() {
  test('Playlist creation and adding song', () async {
    await HiveDatabase.init();
    final repo = PlaylistRepositoryImpl();
    
    // Create playlist
    final pl = await repo.createPlaylist('Test Playlist');
    expect(pl.title, 'Test Playlist');
    
    // Create a dummy song
    final song = Song(
      id: 'test_song_1',
      title: 'Test Song',
      artistName: 'Test Artist',
      thumbnailUrl: '',
      durationMs: 1000,
    );
    
    // Add song
    await repo.addSongToPlaylist(pl.id, song);
    
    // Fetch again
    final fetched = await repo.getPlaylistById(pl.id);
    expect(fetched, isNotNull);
    expect(fetched!.songs.length, 1);
    expect(fetched.songs.first.title, 'Test Song');
  });
}
