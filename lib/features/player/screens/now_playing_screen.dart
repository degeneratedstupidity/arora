import 'dart:async';

import 'package:flutter/physics.dart';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/app_motion.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/usecases/get_video_url_usecase.dart';
import 'package:arora/features/downloads/providers/download_providers.dart';
import 'package:arora/features/library/providers/library_providers.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/features/player/screens/lyrics_screen.dart';
import 'package:arora/features/player/widgets/player_controls.dart';
import 'package:arora/shared/widgets/arora_image.dart';
import 'package:arora/shared/widgets/error_view.dart';
import 'package:arora/shared/widgets/loading_indicator.dart';
import 'package:arora/features/player/widgets/blurred_background.dart';
import 'package:arora/shared/widgets/spring_button.dart';

/// Full-screen Now Playing screen.
///
/// Gestures:
///   Pull down (drag > 150 px or velocity > 600 px/s) → pop back to library.
///   Swipe left on album art → skip next.
///   Swipe right on album art → skip previous.
class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  // ── Pull-to-dismiss ───────────────────────────────────────────────────────
  late final AnimationController _snapCtrl;
  double _dismissOffset = 0;

  @override
  void initState() {
    super.initState();
    // Unbounded controller lets the spring settle to slightly negative
    // values (tiny upward overshoot) for a physical feel.
    _snapCtrl = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        if (mounted) setState(() => _dismissOffset = _snapCtrl.value);
      });
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _snapCtrl.stop();
    // Resist upward drags — only let content move down.
    setState(() {
      _dismissOffset = (_dismissOffset + d.delta.dy).clamp(0.0, double.infinity);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    if (_dismissOffset > 150 || velocity > 600) {
      if (context.canPop()) { context.pop(); } else { context.go('/'); }
      return;
    }
    // Velocity-aware spring snap-back: the release velocity feeds into the
    // simulation so a gentle release feels gentle and a flick feels snappy.
    _snapCtrl.animateWith(
      SpringSimulation(AppMotion.swipeSpring, _dismissOffset, 0.0, velocity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final songAsync = ref.watch(currentSongProvider);

    return songAsync.when(
      loading: () => const Scaffold(body: AroraLoadingIndicator()),
      error: (e, _) => Scaffold(body: ErrorView(message: '$e')),
      data: (song) {
        if (song == null) {
          return Scaffold(
            body: _EmptyState(onBrowse: () => context.go('/')),
          );
        }

        final t = Theme.of(context).extension<AroraTheme>()!;
        final c = t.colors(context);
        final playerMode = ref.watch(playerModeProvider);
        final screenHeight = MediaQuery.of(context).size.height;

        // Opacity fades as content slides down (fully transparent at 300 px)
        final opacity = (1.0 - _dismissOffset / 300.0).clamp(0.0, 1.0);
        // Subtle scale-down during dismiss
        final scale = (1.0 - _dismissOffset / (screenHeight * 5)).clamp(0.92, 1.0);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            // Only detect downward drags — nested scrollables (lyrics sheet)
            // are not part of this screen so there is no conflict.
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            child: Transform.translate(
              offset: Offset(0, _dismissOffset),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Stack(
                    children: [
                      // Blurred album art background
                      BlurredBackground(imageUrl: song.thumbnailUrl),

                      // Content
                      SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Drag handle ─────────────────────────────────
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: 36,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: c.textTertiary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),

                            // ── Top bar ──────────────────────────────────────
                            _TopBar(song: song, colors: c),

                            // ── Audio/Video mode toggle ───────────────────────
                            if (song.hasVideo)
                              _ModeToggle(
                                playerMode: playerMode,
                                colors: c,
                                shapes: t.shapes,
                                onAudio: () => ref
                                    .read(playerModeProvider.notifier)
                                    .update(PlayerMode.audio),
                                onVideo: () => ref
                                    .read(playerModeProvider.notifier)
                                    .update(PlayerMode.video),
                              ),

                            // ── Art / Video ───────────────────────────────────
                            Expanded(
                              child: playerMode == PlayerMode.video && song.hasVideo
                                  ? _VideoView(songId: song.videoId ?? song.id)
                                  : _SwipeableArtView(song: song, shapes: t.shapes),
                            ),

                            // ── Song info ─────────────────────────────────────
                            _SongInfo(song: song, colors: c),

                            // ── Controls ──────────────────────────────────────
                            const Padding(
                              padding: EdgeInsets.only(top: AppSpacing.sm),
                              child: PlayerControls(),
                            ),

                            // ── Bottom row: Lyrics + Queue ────────────────────
                            _BottomActions(
                              colors: c,
                              shapes: t.shapes,
                              onLyrics: () => _showLyricsSheet(context, c),
                              onQueue: () => context.push('/queue'),
                            ),

                            const SizedBox(height: AppSpacing.md),
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
      },
    );
  }

  // ── Bottom sheets ─────────────────────────────────────────────────────────

  void _showLyricsSheet(BuildContext context, AroraColors c) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollController) => Container(
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
              const SizedBox(height: AppSpacing.md),
              Text(
                'Lyrics',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: c.textPrimary),
              ),
              const Expanded(child: LyricsView()),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(
      BuildContext context, WidgetRef ref, Song song, AroraColors c,) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
              leading: Icon(Icons.queue_music_rounded, color: c.textSecondary),
              title: Text('View Queue',
                  style: TextStyle(color: c.textPrimary),),
              onTap: () {
                Navigator.pop(context);
                context.push('/queue');
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.playlist_add_rounded, color: c.textSecondary),
              title: Text('Add to Playlist',
                  style: TextStyle(color: c.textPrimary),),
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistSheet(context, ref, song, c);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistSheet(
      BuildContext context, WidgetRef ref, Song song, AroraColors c,) {
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
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<AroraTheme>()!;
    final c = t.colors(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_off_rounded, size: 64, color: c.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nothing playing',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: onBrowse,
            child: const Text('Browse Music'),
          ),
        ],
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.song, required this.colors});
  final Song song;
  final AroraColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Down-chevron — falls back to home if stack is empty.
          SpringButton(
            pressedScale: 0.85,
            onTap: () =>
                context.canPop() ? context.pop() : context.go('/'),
            child: SizedBox(
              width: AppSpacing.touchTarget,
              height: AppSpacing.touchTarget,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 30,
                color: colors.textPrimary,
              ),
            ),
          ),

          Expanded(
            child: Text(
              'Now Playing',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(
                    color: colors.textSecondary,
                    letterSpacing: 1.0,
                  ),
            ),
          ),

          // Options
          SpringButton(
            pressedScale: 0.85,
            onTap: () {
              final t = Theme.of(context).extension<AroraTheme>()!;
              final state = context.findAncestorStateOfType<_NowPlayingScreenState>();
              state?._showOptionsMenu(context, ref, song, t.colors(context));
            },
            child: SizedBox(
              width: AppSpacing.touchTarget,
              height: AppSpacing.touchTarget,
              child: Icon(
                Icons.more_vert_rounded,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mode toggle (Audio / Video) ───────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.playerMode,
    required this.colors,
    required this.shapes,
    required this.onAudio,
    required this.onVideo,
  });
  final PlayerMode playerMode;
  final AroraColors colors;
  final AroraShapes shapes;
  final VoidCallback onAudio;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceRaised.withAlpha(180),
          borderRadius: shapes.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeTab(
              label: 'Audio',
              icon: Icons.music_note_rounded,
              isSelected: playerMode == PlayerMode.audio,
              colors: colors,
              shapes: shapes,
              onTap: onAudio,
            ),
            _ModeTab(
              label: 'Video',
              icon: Icons.videocam_rounded,
              isSelected: playerMode == PlayerMode.video,
              colors: colors,
              shapes: shapes,
              onTap: onVideo,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.colors,
    required this.shapes,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool isSelected;
  final AroraColors colors;
  final AroraShapes shapes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.surfaceHighest.withAlpha(200)
              : Colors.transparent,
          borderRadius: shapes.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? colors.textPrimary : colors.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? colors.textPrimary : colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Swipeable album art ───────────────────────────────────────────────────────

/// Album art that responds to horizontal swipe gestures.
///
/// Swipe left → skip next, swipe right → skip previous.
/// On gesture end the art spring-snaps back to center.
class _SwipeableArtView extends ConsumerStatefulWidget {
  const _SwipeableArtView({required this.song, required this.shapes});
  final Song song;
  final AroraShapes shapes;

  @override
  ConsumerState<_SwipeableArtView> createState() => _SwipeableArtViewState();
}

class _SwipeableArtViewState extends ConsumerState<_SwipeableArtView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapCtrl;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        if (mounted) setState(() => _dragOffset = _snapCtrl.value);
      });
  }

  @override
  void didUpdateWidget(_SwipeableArtView old) {
    super.didUpdateWidget(old);
    if (old.song.id != widget.song.id) {
      _snapCtrl.stop();
      if (mounted) setState(() => _dragOffset = 0);
    }
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _snapCtrl.stop();
    setState(() => _dragOffset += d.delta.dx);
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    final player = ref.read(audioPlayerServiceProvider);

    if (_dragOffset < -80 || velocity < -500) {
      player.skipNext();
      if (mounted) setState(() => _dragOffset = 0);
      return;
    } else if (_dragOffset > 80 || velocity > 500) {
      player.skipPrevious();
      if (mounted) setState(() => _dragOffset = 0);
      return;
    }

    // Velocity-aware spring: release velocity feeds into simulation.
    _snapCtrl.animateWith(
      SpringSimulation(AppMotion.swipeSpring, _dragOffset, 0.0, velocity),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Compute a subtle rotation: art tilts ±5° at ±120 px drag offset
    final rotateAngle = (_dragOffset / 120).clamp(-1.0, 1.0) * 0.09;

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        child: Transform.translate(
          offset: Offset(_dragOffset, 0),
          child: Transform.rotate(
            angle: rotateAngle,
            child: AspectRatio(
              aspectRatio: 1,
              child: Hero(
                tag: widget.song.id,
                // AnimatedSwitcher keyed on song.id crossfades album art
                // when the song changes (either via swipe or skip buttons).
                child: AnimatedSwitcher(
                  duration: AppMotion.medium,
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: AroraImage(
                    key: ValueKey(widget.song.id),
                    imageUrl: widget.song.thumbnailUrl,
                    borderRadius: widget.shapes.radiusXl,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Song info row ─────────────────────────────────────────────────────────────

class _SongInfo extends ConsumerWidget {
  const _SongInfo({required this.song, required this.colors});
  final Song song;
  final AroraColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  song.artistName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _DownloadButton(song: song, colors: colors),
        ],
      ),
    );
  }
}

// ── Download button ───────────────────────────────────────────────────────────

class _DownloadButton extends ConsumerWidget {
  const _DownloadButton({required this.song, required this.colors});
  final Song song;
  final AroraColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadingIds = ref.watch(downloadingIdsProvider);
    final isDownloading = downloadingIds.contains(song.id);

    if (song.isDownloaded) {
      return Icon(
        Icons.download_done_rounded,
        color: Colors.greenAccent.shade400,
        size: 22,
      );
    }

    if (isDownloading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          color: colors.accent,
          strokeWidth: 2,
        ),
      );
    }

    return SpringButton(
      pressedScale: 0.82,
      onTap: () async {
        ref.read(downloadingIdsProvider.notifier).addId(song.id);
        await ref.read(downloadManagerProvider).download(song);
        ref.read(downloadingIdsProvider.notifier).removeId(song.id);
      },
      child: SizedBox(
        width: AppSpacing.touchTarget,
        height: AppSpacing.touchTarget,
        child: Icon(
          Icons.download_rounded,
          color: colors.textSecondary,
          size: 22,
        ),
      ),
    );
  }
}

// ── Bottom actions bar ────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.colors,
    required this.shapes,
    required this.onLyrics,
    required this.onQueue,
  });
  final AroraColors colors;
  final AroraShapes shapes;
  final VoidCallback onLyrics;
  final VoidCallback onQueue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionPill(
            icon: Icons.lyrics_outlined,
            label: 'Lyrics',
            colors: colors,
            shapes: shapes,
            onTap: onLyrics,
          ),
          _ActionPill(
            icon: Icons.queue_music_rounded,
            label: 'Queue',
            colors: colors,
            shapes: shapes,
            onTap: onQueue,
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.colors,
    required this.shapes,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final AroraColors colors;
  final AroraShapes shapes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SpringButton(
      pressedScale: 0.92,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceRaised.withAlpha(160),
          borderRadius: shapes.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Video view ────────────────────────────────────────────────────────────────

/// Inline video player using chewie. Synchronises video position + play/pause
/// state to the [AudioPlayerService] since the muxed video stream is audio-less.
class _VideoView extends ConsumerStatefulWidget {
  const _VideoView({required this.songId});
  final String songId;

  @override
  ConsumerState<_VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends ConsumerState<_VideoView> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  StreamSubscription? _positionSub;
  StreamSubscription? _playingSub;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final useCase = GetVideoUrlUseCase(ref.read(musicProviderProvider));
      final song = ref.read(currentSongProvider).value;
      if (song == null) return;

      final url = await useCase(song);
      final ctrl = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await ctrl.initialize();

      final audioPlayer = ref.read(audioPlayerServiceProvider);

      await ctrl.seekTo(audioPlayer.position);
      if (audioPlayer.isPlaying) await ctrl.play();

      _positionSub = audioPlayer.positionStream.listen((pos) {
        final vPos = ctrl.value.position;
        if ((pos - vPos).inMilliseconds.abs() > 1000) ctrl.seekTo(pos);
      });

      _playingSub = audioPlayer.isPlayingStream.listen((playing) {
        if (playing && !ctrl.value.isPlaying) {
          ctrl.play();
        } else if (!playing && ctrl.value.isPlaying) {
          ctrl.pause();
        }
      });

      final chewie = ChewieController(
        videoPlayerController: ctrl,
        autoPlay: audioPlayer.isPlaying,
        showControls: false,
        looping: false,
        aspectRatio: ctrl.value.aspectRatio,
      );

      if (mounted) {
        setState(() {
          _videoController = ctrl;
          _chewieController = chewie;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = '$e'; });
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playingSub?.cancel();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const AroraLoadingIndicator();
    if (_error != null) return const ErrorView(message: 'Video unavailable');
    return Chewie(controller: _chewieController!);
  }
}
