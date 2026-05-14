library;

import 'package:flutter/material.dart';

/// Static color constants used as defaults inside [AroraTheme] built-in themes.
///
/// UI widgets must NOT reference these directly — read colors from
/// `Theme.of(context).extension<AroraTheme>()!.colors(context)` instead.
/// These constants exist only so built-in theme definitions stay readable.
abstract final class AppColors {
  // ── Default Dark (monochromatic near-black) ────────────────────────────────
  static const Color darkBg = Color(0xFF080808);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceRaised = Color(0xFF1C1C1C);
  static const Color darkSurfaceHighest = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF808080);
  static const Color darkTextTertiary = Color(0xFF404040);
  static const Color darkPlayButtonBg = Color(0xFFFFFFFF);
  static const Color darkPlayButtonFg = Color(0xFF000000);
  static const Color darkAccent = Color(0xFFFFFFFF);

  // ── Default Light (crisp white) ────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF7F7F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceRaised = Color(0xFFEFEFEF);
  static const Color lightSurfaceHighest = Color(0xFFE2E2E2);
  static const Color lightTextPrimary = Color(0xFF0A0A0A);
  static const Color lightTextSecondary = Color(0xFF6A6A6A);
  static const Color lightTextTertiary = Color(0xFFAAAAAA);
  static const Color lightPlayButtonBg = Color(0xFF0A0A0A);
  static const Color lightPlayButtonFg = Color(0xFFFFFFFF);
  static const Color lightAccent = Color(0xFF0A0A0A);

  // ── Semantic (shared across all themes) ────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);

  // ── Legacy aliases — kept so existing code compiles during migration ────────
  // These will be removed once all widgets read from AroraTheme extension.
  @Deprecated('Read from AroraTheme extension instead')
  static const Color primary = Color(0xFF7C4DFF);
  @Deprecated('Read from AroraTheme extension instead')
  static const Color primaryLight = Color(0xFF9E6FFF);
  @Deprecated('Read from AroraTheme extension instead')
  static const Color primaryDark = Color(0xFF5C2FDF);
  @Deprecated('Read from AroraTheme extension instead')
  static const Color accent = Color(0xFFFFAB40);
  @Deprecated('Read from AroraTheme extension instead')
  static const Color darkBackground = darkBg;
  @Deprecated('Read from AroraTheme extension instead')
  static const Color darkSurfaceElevated = darkSurfaceRaised;
  @Deprecated('Read from AroraTheme extension instead')
  static const Color textPrimaryDark = darkTextPrimary;
  @Deprecated('Read from AroraTheme extension instead')
  static const Color textSecondaryDark = darkTextSecondary;
  @Deprecated('Read from AroraTheme extension instead')
  static const Color lightBackground = lightBg;
  @Deprecated('Read from AroraTheme extension instead')
  static const Color lightSurfaceElevated = lightSurfaceRaised;
  @Deprecated('Read from AroraTheme extension instead')
  static const Color textPrimaryLight = lightTextPrimary;
  @Deprecated('Read from AroraTheme extension instead')
  static const Color textSecondaryLight = lightTextSecondary;
  // lightSurface and darkSurface already defined above as primary tokens.
  @Deprecated('Read from AroraTheme extension instead')
  static const List<Color> playerGradientDark = [
    Color(0xFF1A1028),
    Color(0xFF0D0D12),
  ];
  @Deprecated('Read from AroraTheme extension instead')
  static const List<Color> playerGradientLight = [
    Color(0xFFE8E0F0),
    Color(0xFFF5F5FA),
  ];
}
