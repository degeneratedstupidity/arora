import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/providers/music_provider.dart';

/// Searches for songs using the active [MusicProvider].
///
/// ## Single Responsibility
/// This use-case has exactly one job: delegate a search query to the provider
/// and return the results. Pagination and error conversion happen here,
/// keeping the UI layer free of provider-specific concerns.
final class SearchSongsUseCase {
  const SearchSongsUseCase(this._provider);

  final MusicProvider _provider;

  /// Executes the search.
  ///
  /// [query] must be non-empty (validated by the caller / UI layer).
  /// Returns an empty list when no results are found.
  Future<List<Song>> call(
    String query, {
    int limit = 20,
    int page = 0,
  }) =>
      _provider.searchSongs(query, limit: limit, page: page);
}
