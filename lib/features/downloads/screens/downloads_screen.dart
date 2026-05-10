import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/app_colors.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  const Icon(Icons.download_outlined,
                      size: 64, color: AppColors.textSecondaryDark,),
                  const SizedBox(height: 16),
                  Text(
                    'No downloads yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap ⬇ on any song to download it'),
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
                context.go('/player');
              },
            ),
          );
        },
      ),
    );
  }
}
