import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/core/extensions/duration_extensions.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/shared/widgets/spring_button.dart';
import 'package:just_audio/just_audio.dart';

// ── Progress bar ─────────────────────────────────────────────────────────────

/// Animated scrub bar with position and duration timestamps.
///
/// Polls at 200 ms so the bar moves smoothly on Linux/media_kit where
/// [positionStream] can tick as infrequently as once per second.
/// The [Slider] styling comes entirely from [SliderThemeData] in [ThemeData]
/// (set by [AroraTheme.toMaterialTheme]) — no inline override needed.
class ProgressBarWidget extends ConsumerStatefulWidget {
  const ProgressBarWidget({super.key});

  @override
  ConsumerState<ProgressBarWidget> createState() => _ProgressBarWidgetState();
}

class _ProgressBarWidgetState extends ConsumerState<ProgressBarWidget> {
  double? _dragValue;
  Timer? _ticker;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      final pos = ref.read(audioPlayerServiceProvider).position;
      if (pos != _position) setState(() => _position = pos);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<AroraTheme>()!;
    final c = t.colors(context);
    final song = ref.watch(currentSongProvider).value;
    final duration =
        song?.durationMs != null ? Duration(milliseconds: song!.durationMs!) : null;

    final maxValue = duration?.inMilliseconds.toDouble() ?? 1.0;
    final positionValue = (_dragValue ??
            _position.inMilliseconds
                .toDouble()
                .clamp(0.0, maxValue))
        .clamp(0.0, maxValue);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: positionValue,
          min: 0,
          max: maxValue,
          onChanged: (v) => setState(() => _dragValue = v),
          onChangeEnd: (v) {
            _dragValue = null;
            ref
                .read(audioPlayerServiceProvider)
                .seek(Duration(milliseconds: v.round()));
          },
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.lg + AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _position.toMMSS(),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: c.textSecondary),
              ),
              Text(
                duration?.toMMSS() ?? '0:00',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Full player controls ──────────────────────────────────────────────────────

/// Progress bar + transport row (shuffle / prev / play / next / repeat) +
/// volume slider. Used only in [NowPlayingScreen] — the mini player has its
/// own inline compact controls.
class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).extension<AroraTheme>()!;
    final c = t.colors(context);

    final isPlaying = ref.watch(isPlayingProvider).value ?? false;
    final isLoading = ref.watch(isLoadingProvider).value ?? false;
    final loopMode = ref.watch(loopModeProvider);
    final isShuffle = ref.watch(isShuffleProvider);
    final player = ref.read(audioPlayerServiceProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Scrub bar ───────────────────────────────────────────────────────
        const ProgressBarWidget(),
        const SizedBox(height: AppSpacing.lg),

        // ── Transport row ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Shuffle
              _GhostControl(
                icon: Icons.shuffle_rounded,
                size: 22,
                color: isShuffle ? c.accent : c.textTertiary,
                showDot: isShuffle,
                dotColor: c.accent,
                onTap: () {
                  player.toggleShuffle();
                  ref.read(isShuffleProvider.notifier).update(
                        player.isShuffleEnabled,
                      );
                },
              ),

              // Skip previous
              SpringButton(
                pressedScale: 0.84,
                onTap: player.skipPrevious,
                child: SizedBox(
                  width: AppSpacing.touchTarget,
                  height: AppSpacing.touchTarget,
                  child: Icon(
                    Icons.skip_previous_rounded,
                    color: c.textPrimary,
                    size: 34,
                  ),
                ),
              ),

              // Play / Pause
              SpringButton(
                pressedScale: 0.91,
                onTap: player.togglePlayPause,
                child: _PlayPauseCircle(
                  isPlaying: isPlaying,
                  isLoading: isLoading,
                  colors: c,
                  size: 72,
                ),
              ),

              // Skip next
              SpringButton(
                pressedScale: 0.84,
                onTap: player.skipNext,
                child: SizedBox(
                  width: AppSpacing.touchTarget,
                  height: AppSpacing.touchTarget,
                  child: Icon(
                    Icons.skip_next_rounded,
                    color: c.textPrimary,
                    size: 34,
                  ),
                ),
              ),

              // Repeat
              _GhostControl(
                icon: loopMode == LoopMode.one
                    ? Icons.repeat_one_rounded
                    : Icons.repeat_rounded,
                size: 22,
                color: loopMode != LoopMode.off ? c.accent : c.textTertiary,
                showDot: loopMode != LoopMode.off,
                dotColor: c.accent,
                onTap: () async {
                  await player.cycleLoopMode();
                  ref.read(loopModeProvider.notifier).update(player.loopMode);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Volume ──────────────────────────────────────────────────────────
        _VolumeBar(colors: c),
      ],
    );
  }
}

// ── Play/Pause circle ─────────────────────────────────────────────────────────

class _PlayPauseCircle extends StatelessWidget {
  const _PlayPauseCircle({
    required this.isPlaying,
    required this.isLoading,
    required this.colors,
    required this.size,
  });
  final bool isPlaying;
  final bool isLoading;
  final AroraColors colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.playButtonBg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.playButtonBg.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: isLoading
          ? Padding(
              padding: EdgeInsets.all(size * 0.25),
              child: CircularProgressIndicator(
                color: colors.playButtonFg,
                strokeWidth: 2.5,
              ),
            )
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: child,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                key: ValueKey(isPlaying),
                color: colors.playButtonFg,
                size: size * 0.52,
              ),
            ),
    );
  }
}

// ── Ghost control (shuffle / repeat with optional active dot) ─────────────────

class _GhostControl extends StatelessWidget {
  const _GhostControl({
    required this.icon,
    required this.size,
    required this.color,
    required this.onTap,
    this.showDot = false,
    this.dotColor,
  });
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;
  final bool showDot;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return SpringButton(
      pressedScale: 0.80,
      onTap: onTap,
      child: SizedBox(
        width: AppSpacing.touchTarget,
        height: AppSpacing.touchTarget,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: color, size: size),
            if (showDot)
              Positioned(
                bottom: 8,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Volume ────────────────────────────────────────────────────────────────────

class _VolumeBar extends ConsumerStatefulWidget {
  const _VolumeBar({required this.colors});
  final AroraColors colors;

  @override
  ConsumerState<_VolumeBar> createState() => _VolumeBarState();
}

class _VolumeBarState extends ConsumerState<_VolumeBar> {
  double? _dragVolume;

  @override
  Widget build(BuildContext context) {
    final volume = _dragVolume ?? (ref.watch(volumeProvider).value ?? 1.0);
    final player = ref.read(audioPlayerServiceProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            volume < 0.01
                ? Icons.volume_off_rounded
                : Icons.volume_down_rounded,
            size: 18,
            color: widget.colors.textTertiary,
          ),
          Expanded(
            child: Slider(
              value: volume.clamp(0.0, 1.0),
              min: 0,
              max: 1,
              onChanged: (v) {
                setState(() => _dragVolume = v);
                player.setVolume(v);
              },
              onChangeEnd: (_) => setState(() => _dragVolume = null),
            ),
          ),
          Icon(
            Icons.volume_up_rounded,
            size: 18,
            color: widget.colors.textTertiary,
          ),
        ],
      ),
    );
  }
}
