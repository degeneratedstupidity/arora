import 'package:flutter/material.dart';
import 'package:arora/core/theme/app_colors.dart';

/// A branded loading indicator using [AppColors.primary].
///
/// Drop-in replacement for [CircularProgressIndicator] that respects
/// Arora's design system.
class AroraLoadingIndicator extends StatelessWidget {
  const AroraLoadingIndicator({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
        ),
      );
}
