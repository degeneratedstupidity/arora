import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/core/extensions/duration_extensions.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:just_audio/just_audio.dart';

/// Animated progress bar with position and duration labels.
///
/// Allows seeking by dragging. Updates in real time via [playbackPositionProvider].
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
    // Poll at 200 ms so the bar moves smoothly on Linux/media_kit where
    // positionStream can update as infrequently as once per second.
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
    final song = ref.watch(currentSongProvider).value;
    final duration = song?.durationMs != null
        ? Duration(milliseconds: song!.durationMs!)
        : null;

    final positionValue = _dragValue ??
        (_position.inMilliseconds.toDouble().clamp(
              0,
              duration?.inMilliseconds.toDouble() ?? 0.0,
            ));

    final maxValue = duration?.inMilliseconds.toDouble() ?? 1.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.darkSurfaceElevated,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withAlpha(30),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: positionValue.clamp(0, maxValue),
            min: 0,
            max: maxValue,
            onChanged: (value) => setState(() => _dragValue = value),
            onChangeEnd: (value) {
              _dragValue = null;
              ref.read(audioPlayerServiceProvider).seek(
                    Duration(milliseconds: value.round()),
                  );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _position.toMMSS(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
              ),
              Text(
                duration?.toMMSS() ?? '0:00',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Row of player control buttons: shuffle, prev, play/pause, next, repeat.
class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key, this.compact = false});

  /// When `true`, renders a smaller version for the MiniPlayer bar.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider).value ?? false;
    final isLoading = ref.watch(isLoadingProvider).value ?? false;
    final loopMode = ref.watch(loopModeProvider);
    final isShuffle = ref.watch(isShuffleProvider);
    final player = ref.read(audioPlayerServiceProvider);

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded),
            onPressed: player.skipPrevious,
          ),
          _PlayPauseButton(
            isPlaying: isPlaying,
            isLoading: isLoading,
            onTap: player.togglePlayPause,
            size: 44,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next_rounded),
            onPressed: player.skipNext,
          ),
        ],
      );
    }

    return Column(
      children: [
        const ProgressBarWidget(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Shuffle
            IconButton(
              icon: Icon(
                Icons.shuffle_rounded,
                color: isShuffle ? AppColors.primary : AppColors.textSecondaryDark,
              ),
              onPressed: () {
                player.toggleShuffle();
                ref.read(isShuffleProvider.notifier).update(
                      player.isShuffleEnabled,
                    );
              },
            ),

            // Skip previous
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.skip_previous_rounded),
              onPressed: player.skipPrevious,
            ),

            // Play / Pause
            _PlayPauseButton(
              isPlaying: isPlaying,
              isLoading: isLoading,
              onTap: player.togglePlayPause,
              size: 72,
            ),

            // Skip next
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.skip_next_rounded),
              onPressed: player.skipNext,
            ),

            // Loop mode
            IconButton(
              icon: Icon(
                loopMode == LoopMode.one
                    ? Icons.repeat_one_rounded
                    : Icons.repeat_rounded,
                color: loopMode != LoopMode.off
                    ? AppColors.primary
                    : AppColors.textSecondaryDark,
              ),
              onPressed: () async {
                await player.cycleLoopMode();
                ref.read(loopModeProvider.notifier).update(player.loopMode);
              },
            ),
          ],
        ),
        // Compact volume row — right-aligned, below the transport buttons
        const _VolumeBar(),
      ],
    );
  }
}

/// Compact volume row pinned to the right beneath the transport controls.
class _VolumeBar extends ConsumerStatefulWidget {
  const _VolumeBar();

  @override
  ConsumerState<_VolumeBar> createState() => _VolumeBarState();
}

class _VolumeBarState extends ConsumerState<_VolumeBar> {
  double? _dragVolume;

  @override
  Widget build(BuildContext context) {
    final volume = _dragVolume ?? (ref.watch(volumeProvider).value ?? 1.0);
    final player = ref.read(audioPlayerServiceProvider);

    // Right-aligned compact strip: 🔉 ──●── 🔊  (fixed 160 px wide)
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              volume == 0
                  ? Icons.volume_off_rounded
                  : Icons.volume_down_rounded,
              size: 16,
              color: AppColors.textSecondaryDark,
            ),
            SizedBox(
              width: 130,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.darkSurfaceElevated,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withAlpha(30),
                  trackHeight: 2,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 5),
                ),
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
            ),
            const Icon(
              Icons.volume_up_rounded,
              size: 16,
              color: AppColors.textSecondaryDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onTap,
    required this.size,
  });

  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: size * 0.52,
              ),
      ),
    );
  }
}
