import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arora/core/theme/arora_theme.dart';

/// Full-screen blurred album art background for the Now Playing screen.
///
/// The album art is heavily blurred (sigma 45) to act as an abstract color wash.
/// A vertical gradient overlay is layered on top:
///   - Darker at the top and bottom (where controls and text live).
///   - Lighter in the middle (where the album art floats above the background).
///
/// This is the "floating island" technique used in premium music apps — the
/// foreground art appears to glow above the blurred background because the
/// background underneath the art region is comparatively lighter.
class BlurredBackground extends StatelessWidget {
  const BlurredBackground({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<AroraTheme>()!;
    final c = t.colors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return SizedBox.expand(child: ColoredBox(color: c.background));
    }

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Source image ─────────────────────────────────────────────────
          CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => ColoredBox(color: c.background),
          ),

          // ── Heavy blur — turns the image into an abstract color wash ─────
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
            // Gradient painted on top of the blur, inside the filter:
            //   Top ~35%  : strong overlay → controls readable
            //   Mid ~10%  : light overlay  → album art appears to float
            //   Bottom    : strong overlay → controls readable
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    c.background.withAlpha(isDark ? 210 : 175),
                    c.background.withAlpha(isDark ? 110 : 85),
                    c.background.withAlpha(isDark ? 90 : 65),
                    c.background.withAlpha(isDark ? 175 : 145),
                    c.background.withAlpha(isDark ? 220 : 185),
                  ],
                  stops: const [0.0, 0.25, 0.48, 0.72, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
