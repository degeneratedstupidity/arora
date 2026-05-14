import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/domain/entities/album.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/shared/providers/music_provider_provider.dart';

/// The current search query string.
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

/// Debounced search results for songs.
///
/// Re-runs automatically whenever [searchQueryProvider] changes.
/// Returns an empty list for blank queries without hitting the network.
final songSearchResultsProvider =
    FutureProvider.autoDispose<List<Song>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final provider = ref.watch(musicProviderProvider);
  return provider.searchSongs(query, limit: 20);
});

/// Debounced search results for albums.
final albumSearchResultsProvider =
    FutureProvider.autoDispose<List<Album>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final provider = ref.watch(musicProviderProvider);
  return provider.searchAlbums(query, limit: 10);
});
