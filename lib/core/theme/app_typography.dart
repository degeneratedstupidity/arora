library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Arora's typography definitions.
///
/// Uses Inter (geometric sans-serif) for all text. Scale follows Material 3
/// type roles. Changes from v1: display/headline weights raised to w800,
/// letter-spacing tightened on headers for a premium, editorial feel.
abstract final class AppTypography {
  /// Creates a [TextTheme] using Inter, with [color] as the base text color.
  ///
  /// Headers use ExtraBold (w800) with tight negative tracking.
  /// Secondary text stays Regular (w400) so hierarchy is immediately legible.
  static TextTheme textTheme(Color color) => GoogleFonts.interTextTheme(
        TextTheme(
          // ── Display ─────────────────────────────────────────────────────
          displayLarge: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            color: color,
          ),

          // ── Headline ────────────────────────────────────────────────────
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: color,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: color,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
            color: color,
          ),

          // ── Title (song titles, section headers) ────────────────────────
          titleLarge: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
            color: color,
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            color: color,
          ),
          titleSmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            color: color,
          ),

          // ── Body (lyrics, descriptions) ─────────────────────────────────
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
            color: color,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
            color: color,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
            color: color,
          ),

          // ── Label (timestamps, badges) ──────────────────────────────────
          labelLarge: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: color,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: color,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
            color: color,
          ),
        ),
      );

  /// Linux-specific scale: bump base size by 1 pt since 96-dpi monitors read
  /// smaller than phone screens held close. Applied via [MediaQuery] override
  /// in the desktop shell, not here — this helper is kept for documentation.
  static const double desktopTextScaleFactor = 1.05;
}
