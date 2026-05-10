import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/features/player/widgets/player_controls.dart';

/// Persistent glassmorphic mini player bar.
///
/// Shown above the bottom navigation bar or at the bottom of the sidebar.
/// Tapping navigates to [NowPlayingScreen]. Hidden when nothing is playing.
class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songAsync = ref.watch(currentSongProvider);

    return songAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (song) {
        if (song == null) return const SizedBox.shrink();
        return _MiniPlayerContent(song: song);
      },
    );
  }
}

class _MiniPlayerContent extends ConsumerWidget {
  const _MiniPlayerContent({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: GestureDetector(
        onTap: () => context.push('/player'),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.85),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Progress bar at the very top
                  StreamBuilder<Duration>(
                    stream: ref.read(audioPlayerServiceProvider).positionStream,
                    initialData: ref.read(audioPlayerServiceProvider).position,
                    builder: (context, snap) {
                      final pos = snap.data ?? Duration.zero;
                      final dMs = song.durationMs ?? 1;
                      final progress = dMs > 0
                          ? (pos.inMilliseconds / dMs).clamp(0.0, 1.0)
                          : 0.0;
                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 2,
                          backgroundColor: Colors.transparent,
                          color: colorScheme.primary,
                        ),
                      );
                    },
                  ),

                  // Main row
                  Expanded(
                    child: Row(
                      children: [
                        // Album art
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(20),
                          ),
                          child: song.thumbnailUrl != null
                              ? Hero(
                                  tag: song.id,
                                  child: CachedNetworkImage(
                                    imageUrl: song.thumbnailUrl!,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: AppColors.darkSurfaceElevated,
                                  child: const Icon(
                                    Icons.music_note_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),

                        const SizedBox(width: 12),

                        // Title & artist
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.artistName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        // Compact controls (prev / play-pause / next)
                        const PlayerControls(compact: true),

                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
