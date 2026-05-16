import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/features/search/providers/search_history_notifier.dart';
import 'package:arora/features/search/providers/search_providers.dart';
import 'package:arora/shared/widgets/album_card.dart';
import 'package:arora/shared/widgets/arora_image.dart';
import 'package:arora/shared/widgets/error_view.dart';
import 'package:arora/shared/widgets/loading_indicator.dart';
import 'package:arora/shared/widgets/song_tile.dart';

// Colorful genre grid matching Echo's palette
const _genres = <({String label, Color color})>[
  (label: 'Electronic', color: Color(0xFF2D1B6E)),
  (label: 'Pop', color: Color(0xFF6E1B3D)),
  (label: 'Indie', color: Color(0xFF1B4E6E)),
  (label: 'Jazz', color: Color(0xFF1B6E3D)),
  (label: 'Rock', color: Color(0xFF6E3D1B)),
  (label: 'Hip-Hop', color: Color(0xFF3D1B6E)),
];

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
    } catch (_) {}
  }

  void _applyHistoryItem(String query) {
    _controller.text = query;
    _onQueryChanged(query);
    ref.read(searchHistoryProvider.notifier).add(query);
  }

  void _applyGenre(String genre) {
    _controller.text = genre;
    _onQueryChanged(genre);
    ref.read(searchHistoryProvider.notifier).add(genre);
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
          ? _SearchEmptyView(
              onHistoryTap: _applyHistoryItem,
              onGenreTap: _applyGenre,
            )
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

// ── Empty state: history chips + genre grid ───────────────────────────────────

class _SearchEmptyView extends ConsumerWidget {
  const _SearchEmptyView({
    required this.onHistoryTap,
    required this.onGenreTap,
  });
  final void Function(String) onHistoryTap;
  final void Function(String) onGenreTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(searchHistoryProvider);
    final theme = Theme.of(context);
    final c = theme.extension<AroraTheme>()!.colors(context);

    return CustomScrollView(
      slivers: [
        // ── Recent searches (pill chips) ──────────────────────────────────
        if (history.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: history
                    .map(
                      (query) => _HistoryChip(
                        query: query,
                        onTap: () => onHistoryTap(query),
                        onRemove: () =>
                            ref.read(searchHistoryProvider.notifier).remove(query),
                        colors: c,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],

        // ── Genre grid ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Browse genres',
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _GenreTile(
                genre: _genres[i],
                onTap: () => onGenreTap(_genres[i].label),
              ),
              childCount: _genres.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Pill-shaped history chip ──────────────────────────────────────────────────

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({
    required this.query,
    required this.onTap,
    required this.onRemove,
    required this.colors,
  });
  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final AroraColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 14, right: 4, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: colors.surfaceHighest, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 14, color: colors.textSecondary),
            const SizedBox(width: 6),
            Text(
              query,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: colors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Genre tile ────────────────────────────────────────────────────────────────

class _GenreTile extends ConsumerWidget {
  const _GenreTile({required this.genre, required this.onTap});
  final ({String label, Color color}) genre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnailUrl =
        ref.watch(genreThumbnailProvider(genre.label)).asData?.value;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Solid color: shown while thumbnail loads and as composite base.
            ColoredBox(color: genre.color),
            // Thumbnail image fades in once the provider resolves.
            if (thumbnailUrl != null) AroraImage(imageUrl: thumbnailUrl),
            // Gradient overlay so the label stays legible over any thumbnail.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    genre.color.withAlpha(220),
                    genre.color.withAlpha(80),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -16,
              right: -16,
              child: Icon(
                Icons.music_note_rounded,
                size: 96,
                color: Colors.white.withAlpha(28),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                genre.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── No results ────────────────────────────────────────────────────────────────

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
