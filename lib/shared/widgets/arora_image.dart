import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/core/theme/arora_theme.dart';

/// A unified image wrapper that handles caching, placeholders, and error states
/// for all network images in the app.
///
/// Colors adapt to the active [AroraTheme] automatically.
class AroraImage extends StatelessWidget {
  const AroraImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<AroraTheme>();
    final surfaceColor = t?.colors(context).surfaceRaised ?? AppColors.darkSurfaceRaised;
    final iconColor = t?.colors(context).textTertiary ?? AppColors.darkTextTertiary;

    final placeholder = Container(
      color: surfaceColor,
      width: width,
      height: height,
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: iconColor,
          size: width != null ? width! * 0.4 : 40,
        ),
      ),
    );

    final Widget imageWidget = imageUrl != null && imageUrl!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: imageUrl!,
            width: width,
            height: height,
            fit: fit,
            placeholder: (_, __) => placeholder,
            errorWidget: (_, __, ___) => Container(
              color: surfaceColor,
              width: width,
              height: height,
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
              ),
            ),
          )
        : placeholder;

    if (borderRadius != null && borderRadius! > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: imageWidget,
      );
    }
    return imageWidget;
  }
}
