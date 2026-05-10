import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arora/core/theme/app_colors.dart';

/// A unified image wrapper that handles caching, placeholders,
/// and error states for all network images in the app.
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
    final placeholder = Container(
      color: AppColors.darkSurface,
      width: width,
      height: height,
      child: Center(
        child: Icon(Icons.music_note_rounded, color: AppColors.textSecondaryDark, size: width != null ? width! * 0.4 : 40),
      ),
    );

    final Widget imageWidget = imageUrl != null && imageUrl!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: imageUrl!,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) => placeholder,
            errorWidget: (context, url, error) => Container(
              color: AppColors.darkSurface,
              width: width,
              height: height,
              child: const Center(child: Icon(Icons.error_outline, color: AppColors.error)),
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