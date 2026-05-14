import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/core/extensions/duration_extensions.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/shared/utils/bottom_sheet_utils.dart';

/// A reusable list tile for displaying a [Song].
///
/// Used across Home, Search, Playlists, and Downloads screens.
/// Shows thumbnail, title, artist, duration, and an overflow menu.
class SongTile extends ConsumerWidget {
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

  /// Highlights the tile in accent colour when `true`.
  final bool isPlaying;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = theme.extension<AroraTheme>()!;
    final c = t.colors(context);
    final textColor = isPlaying ? c.accent : null;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: _Thumbnail(url: song.thumbnailUrl, isPlaying: isPlaying, colors: c),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(color: textColor),
      ),
      // Expanded prevents the subtitle row from overflowing when badges are
      // present — the text takes remaining space and ellipsis handles overflow.
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              song.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: c.textSecondary,
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
            Icon(
              Icons.videocam_rounded,
              size: 14,
              color: c.textTertiary,
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
                    color: c.textSecondary,
                  ),
                ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => showSongOptionsMenu(context, ref, song, c),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: c.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    this.url,
    required this.isPlaying,
    required this.colors,
  });
  final String? url;
  final bool isPlaying;
  final AroraColors colors;

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
              color: Colors.black.withAlpha(115),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.equalizer_rounded,
              color: colors.accent,
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
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.music_note_rounded,
          color: colors.textTertiary,
          size: 24,
        ),
      );
}
