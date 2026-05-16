import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/player/providers/player_providers.dart';

/// Echo-style responsive song card grid.
///
/// Cards auto-fit columns based on available width — 160 px per card
/// gives 2 columns on a 360-wide phone, up to 5+ on wide desktop.
class TrendingRail extends ConsumerWidget {
  const TrendingRail({super.key, required this.songs});

  final List<Song> songs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (songs.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: songs.length > 10 ? 10 : songs.length,
      itemBuilder: (context, index) => _SongCard(
        song: songs[index],
        onTap: () {
          ref.read(audioPlayerServiceProvider).playQueue(
                songs,
                startWith: songs[index],
              );
          context.push('/player');
        },
      ),
    );
  }
}

// ── Song card ─────────────────────────────────────────────────────────────────

class _SongCard extends StatefulWidget {
  const _SongCard({required this.song, required this.onTap});
  final Song song;
  final VoidCallback onTap;

  @override
  State<_SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<_SongCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<AroraTheme>()!;
    final c = t.colors(context);
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Square artwork — hover lifts card like Echo
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedScale(
                      scale: _hovered ? 1.07 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      child: widget.song.thumbnailUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.song.thumbnailUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: c.surfaceRaised,
                              child: Icon(
                                Icons.music_note_rounded,
                                size: 40,
                                color: c.textTertiary,
                              ),
                            ),
                    ),
                    // Hover overlay with play button
                    AnimatedOpacity(
                      opacity: _hovered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        color: Colors.black.withAlpha(100),
                        child: Center(
                          child: AnimatedScale(
                            scale: _hovered ? 1.0 : 0.7,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.song.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: c.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
