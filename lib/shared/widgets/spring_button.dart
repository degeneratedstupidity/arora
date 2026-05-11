library;

import 'package:flutter/material.dart';
import 'package:arora/core/theme/app_motion.dart';

/// A button wrapper that applies a spring-physics scale-down on press.
///
/// Tap down → scales to [pressedScale] using [AppMotion.buttonSpring].
/// Tap up / cancel → springs back to 1.0 with gentle overshoot.
///
/// Drop this around any widget — it does not add its own visual decoration.
///
/// ```dart
/// SpringButton(
///   onTap: player.togglePlayPause,
///   child: Container(width: 72, height: 72, ...),
/// )
/// ```
class SpringButton extends StatefulWidget {
  const SpringButton({
    super.key,
    required this.onTap,
    required this.child,
    this.pressedScale = 0.90,
  });

  final VoidCallback onTap;
  final Widget child;

  /// How far down the button scales on press. Default 0.90 = 10% scale-down.
  final double pressedScale;

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
      reverseDuration: AppMotion.spring,
    );
    _scale = Tween<double>(begin: 1.0, end: widget.pressedScale).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOut,
        reverseCurve: AppMotion.springCurve,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();

  void _onTapUp(TapUpDetails _) {
    widget.onTap();
    _ctrl.reverse();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
