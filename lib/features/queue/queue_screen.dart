import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/extensions/duration_extensions.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/services/audio/playback_queue_notifier.dart';
import 'package:arora/shared/widgets/arora_image.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(playbackQueueProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final upcomingSongs = queue.currentIndex + 1 < queue.songs.length
        ? queue.songs.sublist(queue.currentIndex + 1)
        : <Song>[];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Up Next'),
        actions: [
          if (queue.songs.isNotEmpty)
            Switch(
              value: queue.isSmartShuffleEnabled,
              thumbIcon: WidgetStateProperty.all(
                const Icon(Icons.auto_awesome_rounded, size: 16),
              ),
              onChanged: (_) =>
                  ref.read(playbackQueueProvider.notifier).toggleSmartShuffle(),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: queue.songs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.queue_music_rounded,
                      size: 64, color: colorScheme.outlineVariant,),
                  const SizedBox(height: 16),
                  Text('Queue is empty',
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,),),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Currently playing
                if (queue.currentSong != null)
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      label: 'Now Playing',
                      color: colorScheme.primary,
                    ),
                  ),
                if (queue.currentSong != null)
                  SliverToBoxAdapter(
                    child: _QueueTile(
                      song: queue.currentSong!,
                      isPlaying: true,
                      onTap: () => context.push('/player'),
                    ),
                  ),

                // Up next
                if (upcomingSongs.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      label: 'Up Next',
                      trailing: queue.isSmartShuffleEnabled
                          ? Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.auto_awesome_rounded,
                                  size: 14, color: colorScheme.primary,),
                              const SizedBox(width: 4),
                              Text('Smart Shuffle',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.primary,),),
                            ],)
                          : null,
                    ),
                  ),
                SliverList.builder(
                  itemCount: upcomingSongs.length,
                  itemBuilder: (context, i) => _QueueTile(
                    song: upcomingSongs[i],
                    isPlaying: false,
                    onTap: () {
                      ref
                          .read(audioPlayerServiceProvider)
                          .play(upcomingSongs[i]);
                      context.push('/player');
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.color, this.trailing});
  final String label;
  final Color? color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color ?? theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({
    required this.song,
    required this.isPlaying,
    required this.onTap,
  });
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AroraImage(
              imageUrl: song.thumbnailUrl,
              width: 48,
              height: 48,
            ),
          ),
          if (isPlaying)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.graphic_eq_rounded,
                  color: Theme.of(context)
                      .extension<AroraTheme>()!
                      .colors(context)
                      .playButtonFg,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w500,
          color: isPlaying ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(
        song.artistName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: song.durationMs != null
          ? Text(
              Duration(milliseconds: song.durationMs!).toMMSS(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
