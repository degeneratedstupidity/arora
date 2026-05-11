import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/features/search/providers/search_history_notifier.dart';
import 'package:arora/features/search/providers/search_providers.dart';
import 'package:arora/shared/widgets/album_card.dart';
import 'package:arora/shared/widgets/error_view.dart';
import 'package:arora/shared/widgets/loading_indicator.dart';
import 'package:arora/shared/widgets/song_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    ref.read(searchQueryProvider.notifier).update(value);
  }

  void _submitQuery(String value) {
    final q = value.trim();
    if (q.isEmpty) return;
    try {
      ref.read(searchHistoryProvider.notifier).add(q);
    } catch (_) {
      // History save is non-critical — never block playback.
    }
  }

  void _applyHistoryItem(String query) {
    _controller.text = query;
    _onQueryChanged(query);
    ref.read(searchHistoryProvider.notifier).add(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.extension<AroraTheme>()!.colors(context);
    final query = ref.watch(searchQueryProvider);
    final songResults = ref.watch(songSearchResultsProvider);
    final albumResults = ref.watch(albumSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onQueryChanged,
          onSubmitted: _submitQuery,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search songs, artists, albums…',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: c.textSecondary,
            ),
            border: InputBorder.none,
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _controller.clear();
                      _onQueryChanged('');
                    },
                  )
                : null,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: query.trim().isEmpty
          ? _SearchHistoryView(onTap: _applyHistoryItem)
          : CustomScrollView(
              slivers: [
                // ── Song results ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('Songs', style: theme.textTheme.titleMedium),
                  ),
                ),
                songResults.when(
                  loading: () => const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                      child: AroraLoadingIndicator(),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: ErrorView(
                      message: 'Search failed. Check your connection.',
                      onRetry: () => ref.invalidate(songSearchResultsProvider),
                    ),
                  ),
                  data: (songs) => songs.isEmpty
                      ? const SliverToBoxAdapter(
                          child: _NoResults(label: 'No songs found'),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => SongTile(
                              song: songs[i],
                              onTap: () {
                                ref
                                    .read(audioPlayerServiceProvider)
                                    .play(songs[i]);
                                _submitQuery(query);
                                context.push('/player');
                              },
                            ),
                            childCount: songs.length,
                          ),
                        ),
                ),

                // ── Album results ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text('Albums', style: theme.textTheme.titleMedium),
                  ),
                ),
                albumResults.when(
                  loading: () => const SliverToBoxAdapter(
                    child: SizedBox(height: 60, child: AroraLoadingIndicator()),
                  ),
                  error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
                  data: (albums) => albums.isEmpty
                      ? const SliverToBoxAdapter(child: SizedBox())
                      : SliverToBoxAdapter(
                          child: SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: albums.length,
                              itemBuilder: (_, i) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: AlbumCard(album: albums[i]),
                              ),
                            ),
                          ),
                        ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
    );
  }
}

class _SearchHistoryView extends ConsumerWidget {
  const _SearchHistoryView({required this.onTap});
  final void Function(String query) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(searchHistoryProvider);
    final theme = Theme.of(context);
    final c = theme.extension<AroraTheme>()!.colors(context);

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 64, color: c.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Search for any song, artist, or album',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recent searches',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(searchHistoryProvider.notifier).clear(),
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, i) {
              final query = history[i];
              return ListTile(
                leading: Icon(
                  Icons.history_rounded,
                  color: c.textSecondary,
                ),
                title: Text(query, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () =>
                      ref.read(searchHistoryProvider.notifier).remove(query),
                ),
                onTap: () => onTap(query),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .extension<AroraTheme>()!
                    .colors(context)
                    .textSecondary,
              ),
        ),
      );
}
