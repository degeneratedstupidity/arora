import 'package:flutter/material.dart';

/// A branded loading indicator that uses the active theme's primary colour.
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
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 2.5,
          ),
        ),
      );
}
