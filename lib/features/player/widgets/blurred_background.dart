import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:arora/core/theme/app_colors.dart';

class BlurredBackground extends StatelessWidget {
  const BlurredBackground({super.key, this.imageUrl});
  
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const SizedBox.expand(child: ColoredBox(color: AppColors.darkBackground));
    }
    
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base Image
          CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => const ColoredBox(color: AppColors.darkBackground),
          ),
          // Dark overlay to ensure text remains readable
          Container(color: Colors.black.withValues(alpha: 0.5)),
          // Heavy Blur Filter
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 45.0, sigmaY: 45.0),
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),
        ],
      ),
    );
  }
}