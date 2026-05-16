import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/services/liked_songs_service.dart';
import 'package:arora/shared/widgets/spring_button.dart';

class LikeButton extends ConsumerWidget {
  const LikeButton({super.key, required this.song, this.iconSize = 22.0});
  final Song song;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = ref.watch(
      likedSongsProvider.select((songs) => songs.any((s) => s.id == song.id)),
    );
    final c = Theme.of(context).extension<AroraTheme>()!.colors(context);

    return SpringButton(
      pressedScale: 0.8,
      onTap: () => ref.read(likedSongsProvider.notifier).toggle(song),
      child: SizedBox(
        width: AppSpacing.touchTarget,
        height: AppSpacing.touchTarget,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            key: ValueKey(liked),
            liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: iconSize,
            color: liked ? Colors.redAccent : c.textSecondary,
          ),
        ),
      ),
    );
  }
}
