import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/services/download/download_manager.dart';

/// All downloaded songs from the local Isar DB.
final downloadedSongsProvider = FutureProvider<List<Song>>((ref) async {
  final manager = ref.watch(downloadManagerProvider);
  return manager.getDownloadedSongs();
});

/// Stream of [DownloadProgress] events for the active download(s).
final downloadProgressProvider =
    StreamProvider.autoDispose<DownloadProgress>((ref) {
  return ref.watch(downloadManagerProvider).progressStream;
});

/// The set of song IDs currently being downloaded (for UI state).
final downloadingIdsProvider = NotifierProvider<DownloadingIdsNotifier, Set<String>>(DownloadingIdsNotifier.new);

class DownloadingIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void addId(String id) {
    state = {...state, id};
  }

  void removeId(String id) {
    state = {...state}..remove(id);
  }
}
