import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/domain/entities/album.dart';

/// A vertical card displaying an [Album]'s cover art, title, and artist.
///
/// Used in horizontal scrolling rails on the Home and Search screens.
class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
    this.width = 140,
  });

  final Album album;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover art
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: album.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: album.thumbnailUrl!,
                      width: width,
                      height: width,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(width),
                    )
                  : _placeholder(width),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              album.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
            // Artist
            Text(
              album.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.album_rounded,
          color: AppColors.textSecondaryDark,
          size: 40,
        ),
      );
}
