import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/entities/playlist.dart';
import 'package:arora/domain/entities/settings.dart';

class HiveDatabase {
  static const String playlistsBoxName = 'playlistsBox';
  static const String downloadsBoxName = 'downloadsBox';
  static const String settingsBoxName = 'settingsBox';
  static const String searchHistoryBoxName = 'searchHistoryBox';

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    if (!Hive.isAdapterRegistered(SongAdapter().typeId)) {
      Hive.registerAdapter(SongAdapter());
    }
    if (!Hive.isAdapterRegistered(PlaylistAdapter().typeId)) {
      Hive.registerAdapter(PlaylistAdapter());
    }
    if (!Hive.isAdapterRegistered(AppThemeModeAdapter().typeId)) {
      Hive.registerAdapter(AppThemeModeAdapter());
    }
    if (!Hive.isAdapterRegistered(SettingsAdapter().typeId)) {
      Hive.registerAdapter(SettingsAdapter());
    }

    await _openBoxSafe<Playlist>(playlistsBoxName, dir.path);
    await _openBoxSafe<Song>(downloadsBoxName, dir.path);
    await _openBoxSafe<Settings>(settingsBoxName, dir.path);
    await _openBoxSafe<String>(searchHistoryBoxName, dir.path);
  }

  /// Opens a Hive box, removing any stale lock file on failure and retrying once.
  static Future<void> _openBoxSafe<T>(String name, String dirPath) async {
    if (Hive.isBoxOpen(name)) return;
    try {
      await Hive.openBox<T>(name);
    } on FileSystemException {
      // Lock file left behind by a previous crash — delete it and retry.
      final lock = File('$dirPath/${name.toLowerCase()}.lock');
      if (await lock.exists()) await lock.delete();
      await Hive.openBox<T>(name);
    }
  }
}