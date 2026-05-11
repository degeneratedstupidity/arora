import 'dart:ui';

import 'package:flutter/physics.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/app_motion.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/services/audio/audio_player_service.dart';
import 'package:arora/shared/widgets/spring_button.dart';

/// Persistent mini player pill shown above the bottom navigation bar (mobile)
/// or at the bottom of the sidebar (desktop).
///
/// Gestures:
///   Tap / swipe up  → open [NowPlayingScreen]
///   Swipe left      → skip next
///   Swipe right     → skip previous
class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songAsync = ref.watch(currentSongProvider);
    return songAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (song) =>
          song == null ? const SizedBox.shrink() : _MiniPlayerContent(song: song),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MiniPlayerContent extends ConsumerStatefulWidget {
  const _MiniPlayerContent({required this.song});
  final Song song;

  @override
  ConsumerState<_MiniPlayerContent> createState() => _MiniPlayerContentState();
}

class _MiniPlayerContentState extends ConsumerState<_MiniPlayerContent>
    with SingleTickerProviderStateMixin {
  double _dragStartX = 0;
  // Visual drag offset — drives a subtle horizontal shift during swipe.
  double _swipeDx = 0;
  late final AnimationController _swipeCtrl;

  @override
  void initState() {
    super.initState();
    _swipeCtrl = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        if (mounted) setState(() => _swipeDx = _swipeCtrl.value);
      });
  }

  @override
  void dispose() {
    _swipeCtrl.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails d) {
    _dragStartX = d.globalPosition.dx;
    _swipeCtrl.stop();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    setState(() => _swipeDx += d.delta.dx);
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    final dx = d.globalPosition.dx - _dragStartX;
    final player = ref.read(audioPlayerServiceProvider);
    if (dx < -80 || velocity < -500) {
      player.skipNext();
    } else if (dx > 80 || velocity > 500) {
      player.skipPrevious();
    }
    // Spring back to center with release velocity for a physical feel.
    _swipeCtrl.animateWith(
      SpringSimulation(AppMotion.swipeSpring, _swipeDx, 0.0, velocity),
    );
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    if ((d.primaryVelocity ?? 0) < -180) {
      context.push('/player');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<AroraTheme>()!;
    final c = t.colors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final player = ref.read(audioPlayerServiceProvider);

    // Clamp shift to ±90 px so the pill never fully leaves the screen.
    final clampedDx = _swipeDx.clamp(-90.0, 90.0);
    final dragOpacity = (1.0 - _swipeDx.abs() / 240.0).clamp(0.65, 1.0);

    return Transform.translate(
      offset: Offset(clampedDx, 0),
      child: Opacity(
        opacity: dragOpacity,
        child: Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm + 4, 6, AppSpacing.sm + 4, 6,),
      child: GestureDetector(
        onTap: () => context.push('/player'),
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 68,
              decoration: BoxDecoration(
                color: isDark
                    ? c.surface.withAlpha(220)
                    : c.surface.withAlpha(235),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 80 : 28),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // ── Content row ──────────────────────────────────────────
                  Row(
                    children: [
                      // Album art
                      _AlbumArt(song: widget.song, radius: AppSpacing.radiusMd),

                      const SizedBox(width: 12),

                      // Title + artist
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: c.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.song.artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: c.textSecondary),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      // Compact controls
                      _MiniControls(colors: c, player: player),

                      const SizedBox(width: AppSpacing.sm),
                    ],
                  ),

                  // ── Progress line (bottom edge) ───────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _ProgressLine(song: widget.song, accentColor: c.accent),
                  ),
                ],
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

// ── Album art ─────────────────────────────────────────────────────────────────

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.song, required this.radius});
  final Song song;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<AroraTheme>()!;
    final c = t.colors(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Hero(
        tag: song.id,
        child: song.thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: song.thumbnailUrl!,
                width: 68,
                height: 68,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    _PlaceholderArt(size: 68, colors: c),
              )
            : _PlaceholderArt(size: 68, colors: c),
      ),
    );
  }
}

class _PlaceholderArt extends StatelessWidget {
  const _PlaceholderArt({required this.size, required this.colors});
  final double size;
  final AroraColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: colors.surfaceRaised,
      child: Icon(Icons.music_note_rounded, color: colors.textTertiary, size: 28),
    );
  }
}

// ── Compact controls ──────────────────────────────────────────────────────────

class _MiniControls extends ConsumerWidget {
  const _MiniControls({required this.colors, required this.player});
  final AroraColors colors;
  final AudioPlayerService player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider).value ?? false;
    final isLoading = ref.watch(isLoadingProvider).value ?? false;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Skip previous — ghost icon, tertiary color
        _GhostIconButton(
          icon: Icons.skip_previous_rounded,
          color: colors.textSecondary,
          size: 22,
          onTap: player.skipPrevious,
        ),

        const SizedBox(width: 4),

        // Play / pause — filled circle from theme
        SpringButton(
          pressedScale: 0.88,
          onTap: player.togglePlayPause,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.playButtonBg,
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      color: colors.playButtonFg,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: colors.playButtonFg,
                    size: 20,
                  ),
          ),
        ),

        const SizedBox(width: 4),

        // Skip next
        _GhostIconButton(
          icon: Icons.skip_next_rounded,
          color: colors.textSecondary,
          size: 22,
          onTap: player.skipNext,
        ),
      ],
    );
  }
}

class _GhostIconButton extends StatelessWidget {
  const _GhostIconButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SpringButton(
      pressedScale: 0.82,
      onTap: onTap,
      child: SizedBox(
        width: AppSpacing.touchTargetSm,
        height: AppSpacing.touchTargetSm,
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}

// ── Progress line ─────────────────────────────────────────────────────────────

/// Thin 2 dp line at the bottom of the pill that tracks playback position.
/// Uses the same 200 ms polling strategy as the full progress bar.
class _ProgressLine extends ConsumerStatefulWidget {
  const _ProgressLine({required this.song, required this.accentColor});
  final Song song;
  final Color accentColor;

  @override
  ConsumerState<_ProgressLine> createState() => _ProgressLineState();
}

class _ProgressLineState extends ConsumerState<_ProgressLine> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final player = ref.read(audioPlayerServiceProvider);
      final dMs = widget.song.durationMs ?? 1;
      final p = dMs > 0
          ? (player.position.inMilliseconds / dMs).clamp(0.0, 1.0)
          : 0.0;
      if (p != _progress) setState(() => _progress = p);
      Future.delayed(const Duration(milliseconds: 200), _tick);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedFractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: _progress,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          color: widget.accentColor.withAlpha(180),
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(2),
          ),
        ),
      ),
    );
  }
}
