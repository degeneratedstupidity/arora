import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/shared/providers/music_provider_provider.dart';

/// Trending songs for the Home screen "Trending Now" rail.
final trendingProvider = FutureProvider<List<Song>>((ref) async {
  ref.keepAlive();
  final provider = ref.watch(musicProviderProvider);
  return provider.getTrending(limit: 20);
});

/// Genre labels and base search queries shown on the Home screen.
///
/// Queries intentionally omit a year — the year is appended at fetch time
/// inside [genreSongsProvider] so YouTube surfaces current-year releases
/// rather than results pinned to a stale year string.
const homeGenres = <({String label, String query})>[
  (label: 'Pop Hits', query: 'top pop hits'),
  (label: 'Hip-Hop', query: 'best hip hop rap songs'),
  (label: 'Electronic', query: 'electronic dance music'),
];

/// Songs for a specific genre (keyed by the base query string).
///
/// Loads after trending completes and staggers each genre 1.5s apart so that
/// all four home-screen requests never hit YouTube simultaneously — avoiding
/// the rate limit that triggers RequestLimitExceededException.
final genreSongsProvider =
    FutureProvider.family<List<Song>, String>((ref, query) async {
  ref.keepAlive();

  // Wait for trending to finish before firing any genre search.
  try {
    await ref.watch(trendingProvider.future);
  } catch (_) {
    // Proceed even if trending failed (e.g. already rate-limited).
  }

  // Stagger by genre position so requests are spaced 1.5 s apart.
  final index = homeGenres.indexWhere((g) => g.query == query);
  if (index > 0) {
    await Future.delayed(Duration(milliseconds: index * 1500));
  }

  final provider = ref.watch(musicProviderProvider);
  final year = DateTime.now().year;

  // Append current year so YouTube surfaces recent releases.
  // Fall back to the base query if the year-tagged search returns nothing
  // (can happen when YouTube returns non-standard result types that
  // youtube_explode_dart can't parse).
  final yearTaggedQuery = '$query $year';
  final songs = await provider.searchSongs(yearTaggedQuery, limit: 15);
  if (songs.isNotEmpty) return songs;

  return provider.searchSongs(query, limit: 15);
});

/// Songs recommended based on the most-recently played track.
/// Returns empty when nothing has been played yet.
///
/// Uses ref.read (not ref.watch) for recentlyPlayedProvider so this provider
/// only runs once per home screen mount — not on every song change while the
/// user is on the player screen. Each home screen visit fetches fresh results.
final recommendedForYouProvider = FutureProvider<List<Song>>((ref) async {
  final recentlyPlayed = ref.read(recentlyPlayedProvider);
  if (recentlyPlayed.isEmpty) return [];
  final seed = recentlyPlayed.first;
  final provider = ref.watch(musicProviderProvider);
  return provider.getRecommendations(
    seed.id,
    limit: 15,
    artistHint: seed.artistName,
  );
});

/// In-memory list of recently played songs (most-recent first).
/// Populated by [AroraApp] listening to [currentSongProvider].
final recentlyPlayedProvider =
    NotifierProvider<RecentlyPlayedNotifier, List<Song>>(
        RecentlyPlayedNotifier.new,);

class RecentlyPlayedNotifier extends Notifier<List<Song>> {
  static const _maxHistory = 30;

  @override
  List<Song> build() => const [];

  void add(Song song) {
    final deduped = [song, ...state.where((s) => s.id != song.id)];
    state = deduped.take(_maxHistory).toList();
  }
}
