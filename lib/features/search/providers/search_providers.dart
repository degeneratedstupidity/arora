import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/domain/entities/album.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/shared/providers/music_provider_provider.dart';

// Matches the order of _genres in search_screen.dart — used for stagger timing.
const _genreOrder = ['Electronic', 'Pop', 'Indie', 'Jazz', 'Rock', 'Hip-Hop'];

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

/// Thumbnail URL for a genre tile. Keyed by genre label.
///
/// Staggered so all 6 requests don't fire simultaneously. keepAlive so the
/// image is cached for the session and doesn't re-fetch on nav.
final genreThumbnailProvider =
    FutureProvider.family<String?, String>((ref, label) async {
  ref.keepAlive();
  final index = _genreOrder.indexOf(label);
  if (index > 0) {
    await Future.delayed(Duration(milliseconds: index * 800));
  }
  final provider = ref.read(musicProviderProvider);
  try {
    final songs = await provider.searchSongs('$label music', limit: 3);
    return songs.isNotEmpty ? songs.first.thumbnailUrl : null;
  } catch (_) {
    return null;
  }
});

/// Debounced search results for albums.
final albumSearchResultsProvider =
    FutureProvider.autoDispose<List<Album>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final provider = ref.watch(musicProviderProvider);
  return provider.searchAlbums(query, limit: 10);
});
