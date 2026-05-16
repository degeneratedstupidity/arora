import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/home/providers/home_providers.dart';
import 'package:arora/features/home/widgets/trending_rail.dart';
import 'package:arora/features/player/providers/player_providers.dart';
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

          // ── Hero Banner ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0,
              ),
              child: trending.when(
                loading: () => const _HeroPlaceholder(),
                error: (_, __) => const SizedBox.shrink(),
                data: (songs) => songs.isEmpty
                    ? const SizedBox.shrink()
                    : _HeroBanner(
                        song: songs.first,
                        onPlay: () {
                          ref
                              .read(audioPlayerServiceProvider)
                              .playQueue(songs, startWith: songs.first);
                          context.push('/player');
                        },
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

// ── Hero banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends ConsumerWidget {
  const _HeroBanner({required this.song, required this.onPlay});
  final Song song;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider).value ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: SizedBox(
        height: 340,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background artwork
            if (song.thumbnailUrl != null)
              CachedNetworkImage(
                imageUrl: song.thumbnailUrl!,
                fit: BoxFit.cover,
              )
            else
              Container(color: Colors.grey.shade900),

            // Gradient overlay (bottom-heavy, like Echo)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.4, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0x33000000),
                    Color(0xDD000000),
                  ],
                ),
              ),
            ),

            // Content anchored to bottom-left
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'NEW RELEASE FOR YOU',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: Color(0x99FFFFFF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    song.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xBBFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Play Now button
                      GestureDetector(
                        onTap: onPlay,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Play Now',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: const Center(child: AroraLoadingIndicator()),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

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
