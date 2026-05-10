import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/domain/entities/playlist.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/library/providers/library_providers.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/shared/widgets/arora_image.dart';
import 'package:arora/shared/widgets/error_view.dart';
import 'package:arora/shared/widgets/loading_indicator.dart';

/// Library screen showing all user-created playlists.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_rounded),
            tooltip: 'Import YouTube Playlist',
            onPressed: () => context.push('/import_playlist'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Playlist'),
        backgroundColor: AppColors.primary,
      ),
      body: playlistsAsync.when(
        loading: () => const AroraLoadingIndicator(),
        error: (e, _) => ErrorView(
          message: 'Could not load playlists.',
          onRetry: () => ref.invalidate(playlistsProvider),
        ),
        data: (playlists) {
          if (playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.library_music_outlined,
                      size: 64, color: AppColors.textSecondaryDark,),
                  const SizedBox(height: 16),
                  Text('No playlists yet',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondaryDark),),
                  const SizedBox(height: 8),
                  const Text('Tap + to create one'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: playlists.length,
            itemBuilder: (context, i) {
              final pl = playlists[i];
              return Dismissible(
                key: Key(pl.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red.shade700,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) =>
                    ref.read(playlistNotifierProvider.notifier).delete(pl.id),
                child: ListTile(
                  leading: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.queue_music_rounded,
                        color: AppColors.primary,),
                  ),
                  title: Text(pl.title),
                  subtitle: Text('${pl.songs.length} songs',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondaryDark),),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showPlaylistSheet(context, ref, pl),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('New Playlist'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ref
                    .read(playlistNotifierProvider.notifier)
                    .create(ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet showing all songs in [playlist] with play controls.
  void _showPlaylistSheet(
      BuildContext context, WidgetRef ref, Playlist playlist,) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceElevated,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(playlist.title,
                            style: Theme.of(context).textTheme.titleMedium,),
                        Text('${playlist.songs.length} songs',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondaryDark),),
                      ],
                    ),
                  ),
                  if (playlist.songs.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ref
                            .read(audioPlayerServiceProvider)
                            .playQueue(playlist.songs);
                        context.go('/player');
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play All'),
                    ),
                ],
              ),
            ),
            const Divider(height: 24),
            if (playlist.songs.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No songs in this playlist yet.',
                    style: TextStyle(color: AppColors.textSecondaryDark),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: playlist.songs.length,
                  itemBuilder: (context, i) => _PlaylistSongTile(
                    song: playlist.songs[i],
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(audioPlayerServiceProvider).playQueue(
                            playlist.songs,
                            startWith: playlist.songs[i],
                          );
                      context.go('/player');
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistSongTile extends StatelessWidget {
  const _PlaylistSongTile({required this.song, required this.onTap});
  final Song song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AroraImage(imageUrl: song.thumbnailUrl, width: 48, height: 48),
      ),
      title: Text(song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,),
      subtitle: Text(song.artistName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondaryDark),),
      onTap: onTap,
    );
  }
}
