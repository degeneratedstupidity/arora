library;

import 'package:flutter/widgets.dart';

/// Spacing and shape constants for the Arora design system.
///
/// All padding, gap, and radius values in UI code must reference these tokens.
/// Never hardcode pixel values inline.
abstract final class AppSpacing {
  // ── Spacing scale ──────────────────────────────────────────────────────────
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // ── Common insets ──────────────────────────────────────────────────────────
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets screenV = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // ── Touch targets (Material 3 minimum = 48 dp) ─────────────────────────────
  static const double touchTarget = 48;
  static const double touchTargetSm = 40; // compact variants (mini player)

  // ── Shape radii ────────────────────────────────────────────────────────────
  /// Small — buttons, chips, pill tags.
  static const double radiusSm = 12;

  /// Medium — song tiles, mini player pill, search bar.
  static const double radiusMd = 20;

  /// Large — bottom sheets, cards, modals.
  static const double radiusLg = 28;

  /// Extra large — album art on Now Playing, hero images.
  static const double radiusXl = 32;
}
