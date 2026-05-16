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

import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/features/player/screens/lyrics_screen.dart';
import 'package:arora/features/player/widgets/player_controls.dart';
import 'package:arora/shared/widgets/arora_image.dart';
import 'package:arora/shared/widgets/audio_visualizer.dart';
import 'package:arora/shared/widgets/error_view.dart';
import 'package:arora/shared/widgets/loading_indicator.dart';
import 'package:arora/features/player/widgets/blurred_background.dart';
import 'package:arora/shared/widgets/spring_button.dart';
import 'package:arora/shared/utils/bottom_sheet_utils.dart';
import 'package:arora/shared/widgets/like_button.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  // ── Pull-to-dismiss ───────────────────────────────────────────────────────────
  late final AnimationController _snapCtrl;
  double _dismissOffset = 0;

  // ── Visualizer sub-mode ───────────────────────────────────────────────────────
  VisualizerMode _visualizerMode = VisualizerMode.bars;

  @override
  void initState() {
    super.initState();
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
        final isPlaying = ref.watch(isPlayingProvider).value ?? false;
        final screenHeight = MediaQuery.of(context).size.height;

        final opacity = (1.0 - _dismissOffset / 300.0).clamp(0.0, 1.0);
        final scale = (1.0 - _dismissOffset / (screenHeight * 5)).clamp(0.92, 1.0);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
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
                      BlurredBackground(imageUrl: song.thumbnailUrl),

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

                            // ── Mode tab bar (always visible) ─────────────────
                            _FullModeToggle(
                              playerMode: playerMode,
                              hasvideo: song.hasVideo,
                              colors: c,
                              shapes: t.shapes,
                              onMode: (mode) => ref
                                  .read(playerModeProvider.notifier)
                                  .update(mode),
                            ),

                            // ── Art / Video / Lyrics / Visualizer ─────────────
                            Expanded(
                              child: _ContentArea(
                                song: song,
                                playerMode: playerMode,
                                shapes: t.shapes,
                                isPlaying: isPlaying,
                                visualizerMode: _visualizerMode,
                                colors: c,
                                onVisualizerModeChanged: (mode) =>
                                    setState(() => _visualizerMode = mode),
                              ),
                            ),

                            // ── Song info ─────────────────────────────────────
                            _SongInfo(song: song, colors: c),

                            // ── Controls ──────────────────────────────────────
                            const Padding(
                              padding: EdgeInsets.only(top: AppSpacing.sm),
                              child: PlayerControls(),
                            ),

                            // ── Bottom row: Queue ─────────────────────────────
                            _BottomActions(
                              colors: c,
                              shapes: t.shapes,
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
}

// ── Content area — switches between art, video, lyrics, visualizer ────────────

class _ContentArea extends ConsumerWidget {
  const _ContentArea({
    required this.song,
    required this.playerMode,
    required this.shapes,
    required this.isPlaying,
    required this.visualizerMode,
    required this.colors,
    required this.onVisualizerModeChanged,
  });

  final Song song;
  final PlayerMode playerMode;
  final AroraShapes shapes;
  final bool isPlaying;
  final VisualizerMode visualizerMode;
  final AroraColors colors;
  final void Function(VisualizerMode) onVisualizerModeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (playerMode) {
      case PlayerMode.video when song.hasVideo:
        return _VideoView(songId: song.videoId ?? song.id);

      case PlayerMode.lyrics:
        return _LyricsArea(colors: colors, shapes: shapes);

      case PlayerMode.visualizer:
        return _VisualizerArea(
          isPlaying: isPlaying,
          mode: visualizerMode,
          colors: colors,
          onModeChanged: onVisualizerModeChanged,
        );

      default:
        return _SwipeableArtView(song: song, shapes: shapes);
    }
  }
}

// ── Lyrics inline area ────────────────────────────────────────────────────────

class _LyricsArea extends StatelessWidget {
  const _LyricsArea({required this.colors, required this.shapes});
  final AroraColors colors;
  final AroraShapes shapes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: shapes.xl,
        child: Container(
          color: colors.surfaceRaised.withAlpha(120),
          child: const LyricsView(),
        ),
      ),
    );
  }
}

// ── Visualizer inline area ────────────────────────────────────────────────────

class _VisualizerArea extends StatelessWidget {
  const _VisualizerArea({
    required this.isPlaying,
    required this.mode,
    required this.colors,
    required this.onModeChanged,
  });
  final bool isPlaying;
  final VisualizerMode mode;
  final AroraColors colors;
  final void Function(VisualizerMode) onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: colors.surfaceRaised.withAlpha(100)),
            AudioVisualizer(
              isPlaying: isPlaying,
              mode: mode,
              color: colors.textPrimary,
            ),
            // Sub-mode pills at bottom
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.surfaceRaised.withAlpha(200),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: VisualizerMode.values
                        .map(
                          (m) => _VisualizerPill(
                            label: m.name.toUpperCase(),
                            isSelected: m == mode,
                            colors: colors,
                            onTap: () => onModeChanged(m),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisualizerPill extends StatelessWidget {
  const _VisualizerPill({
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final AroraColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colors.playButtonBg : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: isSelected ? colors.playButtonFg : colors.textSecondary,
          ),
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

          SpringButton(
            pressedScale: 0.85,
            onTap: () {
              final t = Theme.of(context).extension<AroraTheme>()!;
              showSongOptionsMenu(context, ref, song, t.colors(context));
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

// ── Full 4-mode toggle ────────────────────────────────────────────────────────

class _FullModeToggle extends StatelessWidget {
  const _FullModeToggle({
    required this.playerMode,
    required this.hasvideo,
    required this.colors,
    required this.shapes,
    required this.onMode,
  });
  final PlayerMode playerMode;
  final bool hasvideo;
  final AroraColors colors;
  final AroraShapes shapes;
  final void Function(PlayerMode) onMode;

  @override
  Widget build(BuildContext context) {
    // Always show Music + Lyrics + Visualizer; show Video only if available
    final modes = <({PlayerMode mode, String label, IconData icon})>[
      (mode: PlayerMode.audio, label: 'Music', icon: Icons.music_note_rounded),
      if (hasvideo)
        (mode: PlayerMode.video, label: 'Video', icon: Icons.videocam_rounded),
      (mode: PlayerMode.lyrics, label: 'Lyrics', icon: Icons.lyrics_outlined),
      (
        mode: PlayerMode.visualizer,
        label: 'Scene',
        icon: Icons.bar_chart_rounded,
      ),
    ];

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
          children: modes
              .map(
                (m) => Flexible(
                  child: _ModeTab(
                    label: m.label,
                    icon: m.icon,
                    isSelected: playerMode == m.mode,
                    colors: colors,
                    shapes: shapes,
                    onTap: () => onMode(m.mode),
                  ),
                ),
              )
              .toList(),
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
          horizontal: AppSpacing.sm,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? colors.textPrimary : colors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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

    _snapCtrl.animateWith(
      SpringSimulation(AppMotion.swipeSpring, _dragOffset, 0.0, velocity),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          LikeButton(song: song),
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
    required this.onQueue,
  });
  final AroraColors colors;
  final AroraShapes shapes;
  final VoidCallback onQueue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
