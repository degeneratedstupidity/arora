import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/library/providers/library_providers.dart';
import 'package:arora/services/liked_songs_service.dart';
import 'package:arora/shared/widgets/loading_indicator.dart';

void showSongOptionsMenu(BuildContext context, WidgetRef ref, Song song, AroraColors c) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Consumer(
      builder: (_, watchRef, __) {
        final liked = watchRef.watch(
          likedSongsProvider.select(
            (songs) => songs.any((s) => s.id == song.id),
          ),
        );
        return Container(
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.surfaceHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: Icon(
                  liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: liked ? Colors.redAccent : c.textSecondary,
                ),
                title: Text(
                  liked ? 'Unlike' : 'Like',
                  style: TextStyle(color: c.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  watchRef.read(likedSongsProvider.notifier).toggle(song);
                },
              ),
              ListTile(
                leading: Icon(Icons.queue_music_rounded, color: c.textSecondary),
                title: Text('View Queue', style: TextStyle(color: c.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/queue');
                },
              ),
              ListTile(
                leading: Icon(Icons.playlist_add_rounded, color: c.textSecondary),
                title: Text('Add to Playlist', style: TextStyle(color: c.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  showAddToPlaylistSheet(context, ref, song, c);
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    ),
  );
}

void showAddToPlaylistSheet(BuildContext context, WidgetRef ref, Song song, AroraColors c) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Consumer(
        builder: (_, ref, __) {
          final playlistsAsync = ref.watch(playlistsProvider);
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, AppSpacing.md, 0, AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.surfaceHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Add to Playlist',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                playlistsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: AroraLoadingIndicator(),
                  ),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Could not load playlists.',
                      style: TextStyle(color: c.textSecondary),
                    ),
                  ),
                  data: (playlists) {
                    if (playlists.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No playlists yet.\nCreate one in the Library tab first.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: c.textSecondary),
                        ),
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: playlists
                          .map(
                            (pl) => ListTile(
                              leading: Icon(
                                Icons.queue_music_rounded,
                                color: c.accent,
                              ),
                              title: Text(
                                pl.title,
                                style: TextStyle(color: c.textPrimary),
                              ),
                              subtitle: Text(
                                '${pl.songs.length} songs',
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () async {
                                Navigator.pop(ctx);
                                await ref
                                    .read(playlistNotifierProvider.notifier)
                                    .addSong(pl.id, song);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added "${song.title}" to ${pl.title}',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
