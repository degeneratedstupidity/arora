/// Arora's typography definitions.
///
/// Uses the Inter typeface (loaded via `google_fonts`) for a clean,
/// modern UI that looks great across all platforms and DPI settings.
///
/// Scale follows Material 3 type roles for semantic consistency.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// @nodoc
abstract final class AppTypography {
  /// Creates a [TextTheme] using Inter, with [color] as the base text color.
  static TextTheme textTheme(Color color) => GoogleFonts.interTextTheme(
        TextTheme(
          // ── Display ─────────────────────────────────────────────────────
          displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
            color: color,
          ),

          // ── Headline ────────────────────────────────────────────────────
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          ),

          // ── Title (song titles, section headers) ────────────────────────
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: color,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
            color: color,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: color,
          ),

          // ── Body (lyrics, descriptions) ─────────────────────────────────
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            color: color,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            color: color,
          ),

          // ── Label (timestamps, badges) ──────────────────────────────────
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.25,
            color: color,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
            color: color,
          ),
        ),
      );
}
