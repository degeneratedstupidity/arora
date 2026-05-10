import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arora/core/extensions/duration_extensions.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/domain/entities/song.dart';

/// A reusable list tile for displaying a [Song].
///
/// Used across Home, Search, Playlists, and Downloads screens.
/// Shows thumbnail, title, artist, duration, and an overflow menu.
class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.trailing,
    this.showDownloadBadge = false,
    this.isPlaying = false,
  });

  final Song song;
  final VoidCallback? onTap;

  /// Optional custom trailing widget (e.g., download progress indicator).
  final Widget? trailing;

  /// Shows an offline badge when `true`.
  final bool showDownloadBadge;

  /// Highlights the tile in primary colour when `true`.
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = isPlaying ? AppColors.primary : null;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: _Thumbnail(url: song.thumbnailUrl, isPlaying: isPlaying),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(color: textColor),
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              song.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
          if (showDownloadBadge && song.isDownloaded) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.download_done_rounded,
              size: 14,
              color: AppColors.success,
            ),
          ],
          if (song.hasVideo) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.videocam_rounded,
              size: 14,
              color: AppColors.textSecondaryDark,
            ),
          ],
        ],
      ),
      trailing: trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (song.durationMs != null)
                Text(
                  Duration(milliseconds: song.durationMs!).toMMSS(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondaryDark,
                size: 20,
              ),
            ],
          ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.url, required this.isPlaying});
  final String? url;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: url != null
              ? CachedNetworkImage(
                  imageUrl: url!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        if (isPlaying)
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.equalizer_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
      ],
    );
  }

  Widget _placeholder() => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.music_note_rounded,
          color: AppColors.textSecondaryDark,
          size: 24,
        ),
      );
}
