/// Arora's complete color palette.
///
/// All colors are defined as design tokens here. No other file in the codebase
/// should hardcode a `Color(0x...)` literal — always reference these tokens.
///
/// The palette uses a deep violet-blue primary with an amber accent, optimised
/// for both dark and light themes.
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  /// Primary brand color — deep aurora violet.
  static const Color primary = Color(0xFF7C4DFF);

  /// Lighter primary shade for hover / focus states.
  static const Color primaryLight = Color(0xFF9E6FFF);

  /// Darker primary shade for pressed states.
  static const Color primaryDark = Color(0xFF5C2FDF);

  /// Accent / highlight — warm amber for play buttons and active indicators.
  static const Color accent = Color(0xFFFFAB40);

  // ── Dark theme surfaces ────────────────────────────────────────────────
  /// App background — near-black with a subtle warm tint.
  static const Color darkBackground = Color(0xFF0D0D12);

  /// Card / surface color on dark background.
  static const Color darkSurface = Color(0xFF1A1A24);

  /// Elevated surface (bottom sheets, dialogs) on dark background.
  static const Color darkSurfaceElevated = Color(0xFF252535);

  // ── Light theme surfaces ───────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F5FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFEEEEF5);

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF0F0F5);
  static const Color textSecondaryDark = Color(0xFF9090A0);
  static const Color textPrimaryLight = Color(0xFF0D0D1A);
  static const Color textSecondaryLight = Color(0xFF5A5A70);

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);

  // ── Player gradient ────────────────────────────────────────────────────
  /// Used as a tonal gradient on the Now Playing screen behind the album art.
  static const List<Color> playerGradientDark = [
    Color(0xFF1A1028),
    Color(0xFF0D0D12),
  ];

  static const List<Color> playerGradientLight = [
    Color(0xFFE8E0F0),
    Color(0xFFF5F5FA),
  ];
}
