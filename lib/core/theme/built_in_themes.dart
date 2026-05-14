library;

import 'package:flutter/material.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/core/theme/arora_theme.dart';

/// All themes bundled with Arora.
///
/// These are the IDs used in [Settings.themeId]. Custom imported themes use
/// user-defined IDs from their JSON file.
///
/// ## My design recommendations (beyond Dark + Light)
///
/// **AMOLED** — Pure `#000000` background. On OLED panels every black pixel is
/// literally turned off, so this is both the most premium-looking dark mode and
/// the most battery-efficient. Essential for Android users.
///
/// **Nord** — The Arctic Studio palette has a huge following in the Linux /
/// terminal community. Soft blue-grey tones work beautifully with most album
/// art. A natural fit for a desktop music player.
///
/// **Rosé Pine** — Warm aubergine darks with a blush rose accent. Unique,
/// tasteful, and popular in creative tools. Differentiates Arora from generic
/// dark-mode apps.
///
/// **Warm Mocha** — My original. Coffee-warm earthy tones with a gold accent.
/// Feels cozy and distinct from the blue-tinted competition.
abstract final class BuiltInThemes {
  // ── Default Dark — monochromatic near-black ──────────────────────────────
  static const AroraTheme dark = AroraTheme(
    id: 'arora_dark',
    name: 'Arora Dark',
    author: 'Arora',
    darkColors: AroraColors(
      background: AppColors.darkBg,
      surface: AppColors.darkSurface,
      surfaceRaised: AppColors.darkSurfaceRaised,
      surfaceHighest: AppColors.darkSurfaceHighest,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      textTertiary: AppColors.darkTextTertiary,
      playButtonBg: AppColors.darkPlayButtonBg,
      playButtonFg: AppColors.darkPlayButtonFg,
      accent: AppColors.darkAccent,
    ),
    lightColors: AroraColors(
      background: AppColors.lightBg,
      surface: AppColors.lightSurface,
      surfaceRaised: AppColors.lightSurfaceRaised,
      surfaceHighest: AppColors.lightSurfaceHighest,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      textTertiary: AppColors.lightTextTertiary,
      playButtonBg: AppColors.lightPlayButtonBg,
      playButtonFg: AppColors.lightPlayButtonFg,
      accent: AppColors.lightAccent,
    ),
  );

  // ── Default Light — crisp white ──────────────────────────────────────────
  // Same as dark.lightColors as primary; dark becomes soft warm-grey.
  static const AroraTheme light = AroraTheme(
    id: 'arora_light',
    name: 'Arora Light',
    author: 'Arora',
    darkColors: AroraColors(
      background: Color(0xFF111111),
      surface: Color(0xFF1A1A1A),
      surfaceRaised: Color(0xFF242424),
      surfaceHighest: Color(0xFF303030),
      textPrimary: Color(0xFFF0F0F0),
      textSecondary: Color(0xFF909090),
      textTertiary: Color(0xFF505050),
      playButtonBg: Color(0xFFF0F0F0),
      playButtonFg: Color(0xFF111111),
      accent: Color(0xFFF0F0F0),
    ),
    lightColors: AroraColors(
      background: AppColors.lightBg,
      surface: AppColors.lightSurface,
      surfaceRaised: AppColors.lightSurfaceRaised,
      surfaceHighest: AppColors.lightSurfaceHighest,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      textTertiary: AppColors.lightTextTertiary,
      playButtonBg: AppColors.lightPlayButtonBg,
      playButtonFg: AppColors.lightPlayButtonFg,
      accent: AppColors.lightAccent,
    ),
  );

  // ── AMOLED — pure black for OLED panels ──────────────────────────────────
  static const AroraTheme amoled = AroraTheme(
    id: 'arora_amoled',
    name: 'AMOLED Black',
    author: 'Arora',
    darkColors: AroraColors(
      background: Color(0xFF000000),
      surface: Color(0xFF080808),
      surfaceRaised: Color(0xFF101010),
      surfaceHighest: Color(0xFF1A1A1A),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFF6E6E6E),
      textTertiary: Color(0xFF383838),
      playButtonBg: Color(0xFFFFFFFF),
      playButtonFg: Color(0xFF000000),
      accent: Color(0xFFFFFFFF),
    ),
    // AMOLED is primarily a dark-mode theme; light variant = default light.
    lightColors: AroraColors(
      background: AppColors.lightBg,
      surface: AppColors.lightSurface,
      surfaceRaised: AppColors.lightSurfaceRaised,
      surfaceHighest: AppColors.lightSurfaceHighest,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      textTertiary: AppColors.lightTextTertiary,
      playButtonBg: AppColors.lightPlayButtonBg,
      playButtonFg: AppColors.lightPlayButtonFg,
      accent: AppColors.lightAccent,
    ),
  );

  // ── Nord — Arctic Studio palette ─────────────────────────────────────────
  static const AroraTheme nord = AroraTheme(
    id: 'arora_nord',
    name: 'Nord',
    author: 'Arora · inspired by Arctic Ice Studio',
    darkColors: AroraColors(
      background: Color(0xFF242933),
      surface: Color(0xFF2E3440),
      surfaceRaised: Color(0xFF3B4252),
      surfaceHighest: Color(0xFF434C5E),
      textPrimary: Color(0xFFECEFF4),
      textSecondary: Color(0xFFD8DEE9),
      textTertiary: Color(0xFF81A1C1),
      playButtonBg: Color(0xFF88C0D0),
      playButtonFg: Color(0xFF2E3440),
      accent: Color(0xFF88C0D0),
    ),
    lightColors: AroraColors(
      background: Color(0xFFECEFF4),
      surface: Color(0xFFFFFFFF),
      surfaceRaised: Color(0xFFE5E9F0),
      surfaceHighest: Color(0xFFD8DEE9),
      textPrimary: Color(0xFF2E3440),
      textSecondary: Color(0xFF4C566A),
      textTertiary: Color(0xFF81A1C1),
      playButtonBg: Color(0xFF5E81AC),
      playButtonFg: Color(0xFFFFFFFF),
      accent: Color(0xFF5E81AC),
    ),
  );

  // ── Rosé Pine — warm aubergine with blush accent ─────────────────────────
  static const AroraTheme rosePine = AroraTheme(
    id: 'arora_rose_pine',
    name: 'Rosé Pine',
    author: 'Arora · inspired by Rosé Pine',
    darkColors: AroraColors(
      background: Color(0xFF191724),
      surface: Color(0xFF1F1D2E),
      surfaceRaised: Color(0xFF26233A),
      surfaceHighest: Color(0xFF393552),
      textPrimary: Color(0xFFE0DEF4),
      textSecondary: Color(0xFF908CAA),
      textTertiary: Color(0xFF555169),
      playButtonBg: Color(0xFFEBBCBA),
      playButtonFg: Color(0xFF191724),
      accent: Color(0xFFEBBCBA),
    ),
    lightColors: AroraColors(
      background: Color(0xFFFAF4ED),
      surface: Color(0xFFFFFAF3),
      surfaceRaised: Color(0xFFF2E9E1),
      surfaceHighest: Color(0xFFDDD0C4),
      textPrimary: Color(0xFF575279),
      textSecondary: Color(0xFF6E6A86),
      textTertiary: Color(0xFF9893A5),
      playButtonBg: Color(0xFFD7827A),
      playButtonFg: Color(0xFFFAF4ED),
      accent: Color(0xFFD7827A),
    ),
  );

  // ── Warm Mocha — original Arora earthy theme ─────────────────────────────
  // Coffee-warm darks with a burnished gold accent. Cozy and distinct from
  // the blue-tinted aesthetic most dark apps default to.
  static const AroraTheme warmMocha = AroraTheme(
    id: 'arora_warm_mocha',
    name: 'Warm Mocha',
    author: 'Arora',
    darkColors: AroraColors(
      background: Color(0xFF0F0D0B),
      surface: Color(0xFF1A1612),
      surfaceRaised: Color(0xFF2A2218),
      surfaceHighest: Color(0xFF3A3020),
      textPrimary: Color(0xFFF5ECD5),
      textSecondary: Color(0xFF9A876A),
      textTertiary: Color(0xFF5C4D3A),
      playButtonBg: Color(0xFFC9A96E),
      playButtonFg: Color(0xFF0F0D0B),
      accent: Color(0xFFC9A96E),
    ),
    lightColors: AroraColors(
      background: Color(0xFFFAF6EE),
      surface: Color(0xFFFFFFFF),
      surfaceRaised: Color(0xFFF0E9D8),
      surfaceHighest: Color(0xFFE0D4BC),
      textPrimary: Color(0xFF2C1F0E),
      textSecondary: Color(0xFF7A6549),
      textTertiary: Color(0xFFB8A088),
      playButtonBg: Color(0xFF8B6914),
      playButtonFg: Color(0xFFFFFFFF),
      accent: Color(0xFF8B6914),
    ),
  );

  /// All built-in themes in display order.
  static const List<AroraTheme> all = [
    dark,
    light,
    amoled,
    nord,
    rosePine,
    warmMocha,
  ];

  /// Resolve by [id]. Returns [dark] if not found.
  static AroraTheme byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => dark);
}
