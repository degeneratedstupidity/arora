import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/features/downloads/providers/download_providers.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/shared/widgets/error_view.dart';
import 'package:arora/shared/widgets/loading_indicator.dart';
import 'package:arora/shared/widgets/song_tile.dart';

/// Downloads screen — shows all offline-available songs.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(downloadedSongsProvider);
    final theme = Theme.of(context);
    final c = theme.extension<AroraTheme>()!.colors(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: songsAsync.when(
        loading: () => const AroraLoadingIndicator(),
        error: (e, _) => ErrorView(
          message: 'Could not load downloads.',
          onRetry: () => ref.invalidate(downloadedSongsProvider),
        ),
        data: (songs) {
          if (songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_outlined,
                      size: 64, color: c.textSecondary,),
                  const SizedBox(height: 16),
                  Text(
                    'No downloads yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap ⬇ on any song to download it',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: songs.length,
            itemBuilder: (context, i) => SongTile(
              song: songs[i],
              showDownloadBadge: true,
              onTap: () {
                ref.read(audioPlayerServiceProvider).play(songs[i]);
                context.push('/player');
              },
            ),
          );
        },
      ),
    );
  }
}
