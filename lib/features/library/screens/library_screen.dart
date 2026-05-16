import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/domain/entities/playlist.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/library/providers/library_providers.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/services/liked_songs_service.dart';
import 'package:arora/shared/widgets/arora_image.dart';
import 'package:arora/shared/widgets/error_view.dart';
import 'package:arora/shared/widgets/loading_indicator.dart';

/// Library screen — playlists displayed in an Echo-style grid.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);
    final likedSongs = ref.watch(likedSongsProvider);
    final theme = Theme.of(context);
    final t = theme.extension<AroraTheme>()!;
    final c = t.colors(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Library',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_rounded),
            tooltip: 'Import YouTube Playlist',
            onPressed: () => context.push('/import_playlist'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref, c, t),
        tooltip: 'New Playlist',
        backgroundColor: c.accent,
        foregroundColor: c.playButtonFg,
        child: const Icon(Icons.add_rounded),
      ),
      body: playlistsAsync.when(
        loading: () => const AroraLoadingIndicator(),
        error: (e, _) => ErrorView(
          message: 'Could not load playlists.',
          onRetry: () => ref.invalidate(playlistsProvider),
        ),
        data: (playlists) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 600 ? 3 : 2;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _LikedSongsBanner(
                      likedSongs: likedSongs,
                      colors: c,
                      shapes: t.shapes,
                      onTap: () => _showLikedSongsSheet(context, ref, likedSongs, c, t),
                    ),
                  ),
                  if (playlists.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.library_music_outlined,
                              size: 64,
                              color: c.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No playlists yet',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: c.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            const Text('Tap + to create one'),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final pl = playlists[i];
                            return _PlaylistCard(
                              playlist: pl,
                              colors: c,
                              shapes: t.shapes,
                              onTap: () => _showPlaylistSheet(ctx, ref, pl, c, t),
                              onDelete: () => ref
                                  .read(playlistNotifierProvider.notifier)
                                  .delete(pl.id),
                            );
                          },
                          childCount: playlists.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCreateDialog(
    BuildContext context,
    WidgetRef ref,
    AroraColors c,
    AroraTheme t,
  ) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: t.shapes.md),
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

  void _showLikedSongsSheet(
    BuildContext context,
    WidgetRef ref,
    List<Song> likedSongs,
    AroraColors c,
    AroraTheme t,
  ) {
    final playlist = Playlist(
      id: likedSongsPlaylistId,
      title: 'Liked Songs',
      songs: likedSongs,
      isEditable: false,
    );
    _showPlaylistSheet(context, ref, playlist, c, t);
  }

  void _showPlaylistSheet(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
    AroraColors c,
    AroraTheme t,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final screenHeight = MediaQuery.of(context).size.height;
        return Container(
          height: screenHeight * 0.7,
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.surfaceHighest,
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
                          Text(
                            playlist.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${playlist.songs.length} songs',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (playlist.songs.isNotEmpty)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(64, 40),
                        ),
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          ref
                              .read(audioPlayerServiceProvider)
                              .playQueue(playlist.songs);
                          context.push('/player');
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play All'),
                      ),
                  ],
                ),
              ),
              const Divider(height: 24),
              if (playlist.songs.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No songs in this playlist yet.',
                      style: TextStyle(color: c.textSecondary),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: playlist.songs.length,
                    itemBuilder: (_, i) => _PlaylistSongTile(
                      song: playlist.songs[i],
                      colors: c,
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        ref.read(audioPlayerServiceProvider).playQueue(
                              playlist.songs,
                              startWith: playlist.songs[i],
                            );
                        context.push('/player');
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Liked Songs pinned banner ─────────────────────────────────────────────────

class _LikedSongsBanner extends StatelessWidget {
  const _LikedSongsBanner({
    required this.likedSongs,
    required this.colors,
    required this.shapes,
    required this.onTap,
  });
  final List<Song> likedSongs;
  final AroraColors colors;
  final AroraShapes shapes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumbnailUrl =
        likedSongs.isNotEmpty ? likedSongs.first.thumbnailUrl : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                // Thumbnail / heart icon square
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppSpacing.radiusLg),
                  ),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: thumbnailUrl != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              AroraImage(
                                imageUrl: thumbnailUrl,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                color: Colors.redAccent.withAlpha(120),
                              ),
                              const Center(
                                child: Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ],
                          )
                        : Container(
                            color: Colors.redAccent.withAlpha(60),
                            child: const Center(
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Colors.redAccent,
                                size: 32,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Liked Songs',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${likedSongs.length} songs',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (likedSongs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.play_circle_filled_rounded,
                      size: 40,
                      color: colors.accent,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Playlist grid card ────────────────────────────────────────────────────────

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.playlist,
    required this.colors,
    required this.shapes,
    required this.onTap,
    required this.onDelete,
  });
  final Playlist playlist;
  final AroraColors colors;
  final AroraShapes shapes;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  String? get _thumbnailUrl =>
      playlist.thumbnailUrl ??
      (playlist.songs.isNotEmpty ? playlist.songs.first.thumbnailUrl : null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Square artwork area — fills the Expanded space
        Expanded(
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              // Immediate tap — no long-press disambiguation delay
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail or icon placeholder
                  _thumbnailUrl != null
                      ? AroraImage(
                          imageUrl: _thumbnailUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: colors.surfaceRaised,
                          child: Icon(
                            Icons.queue_music_rounded,
                            color: colors.accent,
                            size: 48,
                          ),
                        ),
                  // Gradient overlay for legibility
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xAA000000)],
                        ),
                      ),
                    ),
                  ),
                  // Play icon at bottom-right of art
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Title row with delete button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    '${playlist.songs.length} tracks',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Delete via popup — no tap-delay side effect
            if (playlist.isEditable)
              SizedBox(
                width: 28,
                height: 28,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  color: colors.surfaceRaised,
                  icon: Icon(Icons.more_horiz_rounded, color: colors.textTertiary),
                  onSelected: (v) {
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Playlist song tile (inside sheet) ────────────────────────────────────────

class _PlaylistSongTile extends StatelessWidget {
  const _PlaylistSongTile({
    required this.song,
    required this.colors,
    required this.onTap,
  });
  final Song song;
  final AroraColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AroraImage(imageUrl: song.thumbnailUrl, width: 48, height: 48),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        song.artistName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: colors.textSecondary),
      ),
      onTap: onTap,
    );
  }
}
