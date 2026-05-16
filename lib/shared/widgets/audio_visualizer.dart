import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum VisualizerMode { bars, wave, orbit }

/// Canvas-based audio visualizer with three animated modes.
///
/// Renders simulated audio data (no real FFT — mirrors Echo's mock approach).
/// When [isPlaying] is true the bars animate toward random targets; when false
/// they decay smoothly to zero.
class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer({
    super.key,
    this.isPlaying = false,
    this.mode = VisualizerMode.bars,
    this.color,
  });

  final bool isPlaying;
  final VisualizerMode mode;
  final Color? color;

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _rng = math.Random();
  final List<double> _data = List.filled(48, 0.05);

  double _orbitAngle = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    setState(() {
      if (widget.isPlaying) {
        for (var i = 0; i < _data.length; i++) {
          final target = _rng.nextDouble() * 0.85 + 0.1;
          _data[i] = _data[i] + (target - _data[i]) * 0.18;
        }
        _orbitAngle += 0.015;
      } else {
        for (var i = 0; i < _data.length; i++) {
          _data[i] = _data[i] * 0.92;
        }
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.color ?? Theme.of(context).colorScheme.onSurface;

    return Opacity(
      opacity: 0.75,
      child: CustomPaint(
        painter: _VisualizerPainter(
          data: List.unmodifiable(_data),
          mode: widget.mode,
          color: color,
          orbitAngle: _orbitAngle,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  const _VisualizerPainter({
    required this.data,
    required this.mode,
    required this.color,
    required this.orbitAngle,
  });

  final List<double> data;
  final VisualizerMode mode;
  final Color color;
  final double orbitAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    switch (mode) {
      case VisualizerMode.bars:
        _drawBars(canvas, size, paint);
      case VisualizerMode.wave:
        _drawWave(canvas, size, paint);
      case VisualizerMode.orbit:
        _drawOrbit(canvas, size, paint);
    }
  }

  void _drawBars(Canvas canvas, Size size, Paint paint) {
    final barW = size.width / data.length;
    for (var i = 0; i < data.length; i++) {
      final h = data[i] * size.height * 0.6;
      final left = i * barW + 1;
      final top = size.height / 2 - h / 2;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barW - 2, h),
        const Radius.circular(2),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  void _drawWave(Canvas canvas, Size size, Paint paint) {
    if (data.isEmpty) return;
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    for (var i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height / 2 + (data[i] - 0.5) * size.height * 0.4;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, stroke);
  }

  void _drawOrbit(Canvas canvas, Size size, Paint paint) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(size.width, size.height) * 0.28;

    // Dashed orbit ring
    final ringPaint = Paint()
      ..color = color.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(cx, cy), radius, ringPaint);

    // Orbiting dots
    const dotCount = 12;
    for (var i = 0; i < dotCount && i < data.length; i++) {
      final angle = (i / dotCount) * math.pi * 2 + orbitAngle;
      final r = radius + data[i] * 36;
      final x = cx + math.cos(angle) * r;
      final y = cy + math.sin(angle) * r;
      canvas.drawCircle(Offset(x, y), 3.5, paint);
    }
  }

  @override
  bool shouldRepaint(_VisualizerPainter old) =>
      old.data != data || old.mode != mode || old.orbitAngle != orbitAngle;
}
