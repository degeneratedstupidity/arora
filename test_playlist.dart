import 'package:flutter/material.dart';
import 'package:arora/data/datasources/local/hive_database.dart';
import 'package:arora/data/repositories/playlist_repository_impl.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:hive_ce/hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.init();
  final repo = PlaylistRepositoryImpl();
  
  // Create playlist
  final pl = await repo.createPlaylist('Test Playlist');
  print('Created playlist: ${pl.title} (ID: ${pl.id})');
  
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
  print('Added song to playlist');
  
  // Fetch again
  final fetched = await repo.getPlaylistById(pl.id);
  print('Fetched playlist songs length: ${fetched?.songs.length}');
  
  if (fetched != null && fetched.songs.isNotEmpty) {
    print('First song: ${fetched.songs.first.title}');
  }
}
