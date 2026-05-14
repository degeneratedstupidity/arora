import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/features/home/providers/home_providers.dart';
import 'package:arora/features/home/widgets/trending_rail.dart';
import 'package:arora/shared/widgets/error_view.dart';
import 'package:arora/shared/widgets/loading_indicator.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingProvider);
    final recommended = ref.watch(recommendedForYouProvider);
    final recentlyPlayed = ref.watch(recentlyPlayedProvider);
    final theme = Theme.of(context);
    final t = theme.extension<AroraTheme>()!;
    final c = t.colors(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                Text(
                  'Arora',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Search',
                onPressed: () => context.go('/search'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),

          // ── Search shortcut card ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0,
              ),
              child: GestureDetector(
                onTap: () => context.go('/search'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: t.shapes.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: c.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        'Search songs, artists, albums…',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Trending Now ──────────────────────────────────────────────────
          const _SectionHeader(title: 'Trending Now', topPadding: 28),
          SliverToBoxAdapter(
            child: trending.when(
              loading: () => const SizedBox(
                height: 220,
                child: AroraLoadingIndicator(),
              ),
              error: (e, _) => SizedBox(
                height: 220,
                child: ErrorView(
                  message: 'Could not load trending songs.',
                  onRetry: () => ref.invalidate(trendingProvider),
                ),
              ),
              data: (songs) => TrendingRail(songs: songs),
            ),
          ),

          // ── Recommended for You (only after first play) ───────────────────
          if (recentlyPlayed.isNotEmpty) ...[
            _SectionHeader(
              title: 'Because you listened to ${recentlyPlayed.first.title}',
              topPadding: 28,
            ),
            SliverToBoxAdapter(
              child: recommended.when(
                loading: () => const SizedBox(
                  height: 220,
                  child: AroraLoadingIndicator(),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (songs) => songs.isEmpty
                    ? const SizedBox.shrink()
                    : TrendingRail(songs: songs),
              ),
            ),
          ],

          // ── Genre sections ────────────────────────────────────────────────
          for (final genre in homeGenres) ...[
            _SectionHeader(title: genre.label, topPadding: 28),
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, _) {
                  final genreAsync =
                      ref.watch(genreSongsProvider(genre.query));
                  return genreAsync.when(
                    loading: () => const SizedBox(
                      height: 220,
                      child: AroraLoadingIndicator(),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (songs) => songs.isEmpty
                        ? const SizedBox.shrink()
                        : TrendingRail(songs: songs),
                  );
                },
              ),
            ),
          ],

          // ── Bottom padding for MiniPlayer ─────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.topPadding = 16});

  final String title;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.md, topPadding, AppSpacing.md, 8),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
