import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/player/providers/player_providers.dart';

/// A horizontally scrolling rail of [Song] cards for the Home screen.
class TrendingRail extends ConsumerWidget {
  const TrendingRail({super.key, required this.songs});

  final List<Song> songs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (songs.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return _TrendingCard(
            song: songs[index],
            onTap: () {
              ref.read(audioPlayerServiceProvider).playQueue(
                    songs,
                    startWith: songs[index],
                  );
              context.go('/player');
            },
          );
        },
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.song, this.onTap});

  final Song song;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: song.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: song.thumbnailUrl!,
                      height: 140,
                      width: 160,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 140,
                      width: 160,
                      color: AppColors.darkSurfaceElevated,
                      child: const Icon(
                        Icons.music_note_rounded,
                        size: 48,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                      fontSize: 11,
                    ),
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
