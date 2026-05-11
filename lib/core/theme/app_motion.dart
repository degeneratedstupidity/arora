library;

import 'package:flutter/widgets.dart';

/// Animation constants and spring physics for the Arora design system.
///
/// All durations, curves, and spring parameters must come from here.
/// The goal is a UI that feels *alive but not distracting*:
///   - Controls respond instantly (fast).
///   - Pages/sheets arrive with purpose (medium, emphasized curve).
///   - Dismissals feel physical (spring settle, slow).
abstract final class AppMotion {
  // ── Durations ──────────────────────────────────────────────────────────────

  /// Button tap feedback scale pulse.
  static const Duration fast = Duration(milliseconds: 120);

  /// Tab switches, progress bar, animated containers.
  static const Duration medium = Duration(milliseconds: 260);

  /// Full-screen transitions, sheet expand/collapse.
  static const Duration slow = Duration(milliseconds: 400);

  /// Album art swipe settle (spring handles the curve, not duration).
  static const Duration spring = Duration(milliseconds: 500);

  // ── Curves ─────────────────────────────────────────────────────────────────

  /// Standard: enter + exit transitions.
  static const Curve standard = Curves.easeInOut;

  /// Emphasized: element arriving on screen (snappy out).
  static const Curve emphasized = Curves.easeOutCubic;

  /// Decelerate: sheet arriving from bottom.
  static const Curve decelerate = Curves.decelerate;

  /// Spring: swipe-settle, album art bounce.
  static const Curve springCurve = Curves.elasticOut;

  // ── Spring physics ─────────────────────────────────────────────────────────

  /// Tight spring for button press scale feedback.
  /// High stiffness + heavy damping → fast snap with no wobble.
  static SpringDescription get buttonSpring => const SpringDescription(
        mass: 1,
        stiffness: 600,
        damping: 35,
      );

  /// Loose spring for album art swipe-back settle.
  /// Lower stiffness → gentle bounce that feels physical.
  static SpringDescription get swipeSpring => const SpringDescription(
        mass: 1,
        stiffness: 280,
        damping: 26,
      );

  /// Sheet expand/collapse spring.
  static SpringDescription get sheetSpring => const SpringDescription(
        mass: 1,
        stiffness: 340,
        damping: 30,
      );
}
