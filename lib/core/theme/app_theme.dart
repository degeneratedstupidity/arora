/// Arora's [ThemeData] factory for light and dark modes.
///
/// All theme tokens (colors, typography, shapes) are derived from
/// [AppColors] and [AppTypography] — never hardcoded inline.
///
/// ## Usage
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ref.watch(themeModeProvider),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/core/theme/app_typography.dart';

/// @nodoc
abstract final class AppTheme {
  // ── Shared shape ───────────────────────────────────────────────────────
  static const _cardRadius = Radius.circular(16);
  static const _buttonRadius = Radius.circular(12);

  // ── Dark Theme ─────────────────────────────────────────────────────────

  /// The primary dark [ThemeData] for Arora.
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: Colors.black,
          surface: AppColors.darkSurface,
          onSurface: AppColors.textPrimaryDark,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        textTheme: AppTypography.textTheme(AppColors.textPrimaryDark),
        cardTheme: const CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(_cardRadius),
          ),
          margin: EdgeInsets.zero,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(_buttonRadius),
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.darkSurfaceElevated,
          thumbColor: AppColors.primary,
          overlayColor: AppColors.primary.withAlpha(30),
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondaryDark,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerColor: AppColors.darkSurfaceElevated,
        iconTheme: const IconThemeData(color: AppColors.textSecondaryDark),
        primaryIconTheme: const IconThemeData(color: AppColors.primary),
      );

  // ── Light Theme ────────────────────────────────────────────────────────

  /// The light [ThemeData] for Arora.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: Colors.black,
          surface: AppColors.lightSurface,
          onSurface: AppColors.textPrimaryLight,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        textTheme: AppTypography.textTheme(AppColors.textPrimaryLight),
        cardTheme: const CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(_cardRadius),
          ),
          margin: EdgeInsets.zero,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(_buttonRadius),
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.lightSurfaceElevated,
          thumbColor: AppColors.primary,
          overlayColor: AppColors.primary.withAlpha(30),
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondaryLight,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerColor: AppColors.lightSurfaceElevated,
        iconTheme: const IconThemeData(color: AppColors.textSecondaryLight),
        primaryIconTheme: const IconThemeData(color: AppColors.primary),
      );
}
