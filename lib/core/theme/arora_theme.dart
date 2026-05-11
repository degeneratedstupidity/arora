library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/app_typography.dart';

// ── Color set for one brightness level ───────────────────────────────────────

/// All color tokens for a single brightness variant (dark or light).
///
/// Theme authors fill in these 10 values; everything else in [AroraTheme]
/// is derived from them or stays constant across themes.
@immutable
class AroraColors {
  const AroraColors({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceHighest,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.playButtonBg,
    required this.playButtonFg,
    required this.accent,
  });

  /// Scaffold / page background.
  final Color background;

  /// Cards, list items, mini player.
  final Color surface;

  /// Modals, bottom sheets, elevated panels.
  final Color surfaceRaised;

  /// Hover / pressed states, active indicators.
  final Color surfaceHighest;

  /// Primary text — song titles, headings.
  final Color textPrimary;

  /// Secondary text — artist names, timestamps.
  final Color textSecondary;

  /// Tertiary text — inactive icons, dim labels.
  final Color textTertiary;

  /// Play/Pause button background.
  final Color playButtonBg;

  /// Play/Pause icon inside the button.
  final Color playButtonFg;

  /// Active indicator for shuffle, repeat, progress fill.
  final Color accent;

  AroraColors lerp(AroraColors? other, double t) {
    if (other == null) return this;
    return AroraColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceHighest: Color.lerp(surfaceHighest, other.surfaceHighest, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      playButtonBg: Color.lerp(playButtonBg, other.playButtonBg, t)!,
      playButtonFg: Color.lerp(playButtonFg, other.playButtonFg, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }

  Map<String, dynamic> toJson() => {
        'background': background.toARGB32(),
        'surface': surface.toARGB32(),
        'surfaceRaised': surfaceRaised.toARGB32(),
        'surfaceHighest': surfaceHighest.toARGB32(),
        'textPrimary': textPrimary.toARGB32(),
        'textSecondary': textSecondary.toARGB32(),
        'textTertiary': textTertiary.toARGB32(),
        'playButtonBg': playButtonBg.toARGB32(),
        'playButtonFg': playButtonFg.toARGB32(),
        'accent': accent.toARGB32(),
      };

  static AroraColors fromJson(Map<String, dynamic> j) => AroraColors(
        background: Color(j['background'] as int),
        surface: Color(j['surface'] as int),
        surfaceRaised: Color(j['surfaceRaised'] as int),
        surfaceHighest: Color(j['surfaceHighest'] as int),
        textPrimary: Color(j['textPrimary'] as int),
        textSecondary: Color(j['textSecondary'] as int),
        textTertiary: Color(j['textTertiary'] as int),
        playButtonBg: Color(j['playButtonBg'] as int),
        playButtonFg: Color(j['playButtonFg'] as int),
        accent: Color(j['accent'] as int),
      );
}

// ── Shape tokens ──────────────────────────────────────────────────────────────

/// Border radii for the theme. Defaults match [AppSpacing] constants.
/// Theme authors can override to create rounder or sharper shapes.
@immutable
class AroraShapes {
  const AroraShapes({
    this.radiusSm = AppSpacing.radiusSm,
    this.radiusMd = AppSpacing.radiusMd,
    this.radiusLg = AppSpacing.radiusLg,
    this.radiusXl = AppSpacing.radiusXl,
  });

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;

  BorderRadius get sm => BorderRadius.circular(radiusSm);
  BorderRadius get md => BorderRadius.circular(radiusMd);
  BorderRadius get lg => BorderRadius.circular(radiusLg);
  BorderRadius get xl => BorderRadius.circular(radiusXl);

  AroraShapes lerp(AroraShapes? other, double t) {
    if (other == null) return this;
    return AroraShapes(
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
    );
  }

  Map<String, dynamic> toJson() => {
        'radiusSm': radiusSm,
        'radiusMd': radiusMd,
        'radiusLg': radiusLg,
        'radiusXl': radiusXl,
      };

  static AroraShapes fromJson(Map<String, dynamic> j) => AroraShapes(
        radiusSm: (j['radiusSm'] as num).toDouble(),
        radiusMd: (j['radiusMd'] as num).toDouble(),
        radiusLg: (j['radiusLg'] as num).toDouble(),
        radiusXl: (j['radiusXl'] as num).toDouble(),
      );
}

// ── The ThemeExtension ────────────────────────────────────────────────────────

/// Arora's complete design token set, exposed as a Flutter [ThemeExtension].
///
/// ## For widget authors
/// ```dart
/// final t = Theme.of(context).extension<AroraTheme>()!;
/// final c = t.colors(context); // right variant for current brightness
/// Container(color: c.surface, borderRadius: t.shapes.md.toRadius());
/// ```
///
/// ## For theme authors
/// Populate [darkColors] and [lightColors] with your palette, set [id] and
/// [name], then serialize with [toJson] to produce a `.arora-theme` file.
/// Users import it via Settings → Themes → Import.
///
/// ## JSON format (v1.0)
/// ```json
/// {
///   "aroraTheme": "1.0",
///   "id": "my_theme",
///   "name": "My Theme",
///   "author": "Your Name",
///   "dark":  { "background": 4278190080, ... },
///   "light": { "background": 4293519863, ... },
///   "shapes": { "radiusSm": 12, "radiusMd": 20, "radiusLg": 28, "radiusXl": 32 }
/// }
/// ```
/// Colors are stored as 32-bit ARGB integers (same as [Color.toARGB32]).
@immutable
class AroraTheme extends ThemeExtension<AroraTheme> {
  const AroraTheme({
    required this.id,
    required this.name,
    this.author,
    required this.darkColors,
    required this.lightColors,
    this.shapes = const AroraShapes(),
  });

  /// Unique stable identifier, e.g. `'arora_dark'` or `'my_custom_theme'`.
  final String id;

  /// Human-readable display name shown in the Settings theme gallery.
  final String name;

  /// Optional author credit shown beneath the name.
  final String? author;

  final AroraColors darkColors;
  final AroraColors lightColors;
  final AroraShapes shapes;

  // ── Convenience accessors ─────────────────────────────────────────────────

  /// Colors for the given brightness.
  AroraColors colorsFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkColors : lightColors;

  /// Colors matching the current [BuildContext] brightness.
  AroraColors colors(BuildContext context) =>
      colorsFor(Theme.of(context).brightness);

  // ── MaterialTheme generation ──────────────────────────────────────────────

  /// Generates a complete [ThemeData] for one brightness variant.
  ///
  /// Both [toMaterialTheme(Brightness.dark)] and [toMaterialTheme(Brightness.light)]
  /// are called by [theme_provider.dart] and passed to [MaterialApp].
  ThemeData toMaterialTheme(Brightness brightness) {
    final c = colorsFor(brightness);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.playButtonFg,
      primaryContainer: c.surfaceHighest,
      onPrimaryContainer: c.textPrimary,
      secondary: c.accent,
      onSecondary: c.playButtonFg,
      secondaryContainer: c.surfaceRaised,
      onSecondaryContainer: c.textSecondary,
      tertiary: c.textTertiary,
      onTertiary: c.textPrimary,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      outline: c.surfaceHighest,
      outlineVariant: c.surfaceRaised,
      error: const Color(0xFFEF5350),
      onError: Colors.white,
      surfaceContainerHighest: c.surfaceHighest,
      surfaceContainer: c.surfaceRaised,
      surfaceContainerLow: c.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      extensions: [this],
      textTheme: AppTypography.textTheme(c.textPrimary),

      // Cards
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: shapes.md),
      ),

      // Slider (progress bar + volume)
      sliderTheme: SliderThemeData(
        activeTrackColor: c.accent,
        inactiveTrackColor: c.surfaceHighest,
        thumbColor: c.accent,
        overlayColor: c.accent.withAlpha(30),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),

      // Bottom navigation (Android mobile)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.surfaceHighest,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: c.textPrimary, size: 24);
          }
          return IconThemeData(color: c.textTertiary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            );
          }
          return TextStyle(color: c.textTertiary, fontSize: 11);
        }),
      ),

      // Navigation rail (Linux desktop sidebar)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surface,
        selectedIconTheme: IconThemeData(color: c.textPrimary),
        unselectedIconTheme: IconThemeData(color: c.textTertiary),
        selectedLabelTextStyle: TextStyle(
          color: c.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(color: c.textTertiary, fontSize: 12),
        indicatorColor: c.surfaceHighest,
        elevation: 0,
      ),

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.textTheme(c.textPrimary).titleLarge,
      ),

      // List tiles
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      ),

      // Bottom sheets
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceRaised,
        modalBackgroundColor: c.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(shapes.radiusLg),
          ),
        ),
        elevation: 0,
        modalElevation: 0,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: shapes.lg),
        elevation: 0,
      ),

      // Chips / segmented button
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceRaised,
        selectedColor: c.surfaceHighest,
        labelStyle: TextStyle(color: c.textPrimary),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: shapes.sm),
      ),

      // Divider
      dividerColor: c.surfaceRaised,
      dividerTheme: DividerThemeData(color: c.surfaceRaised, space: 1),

      // Icon defaults
      iconTheme: IconThemeData(color: c.textSecondary, size: 24),
      primaryIconTheme: IconThemeData(color: c.accent, size: 24),

      // Filled button (used for primary CTAs)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.playButtonBg,
          foregroundColor: c.playButtonFg,
          shape: RoundedRectangleBorder(borderRadius: shapes.sm),
          minimumSize: const Size(double.infinity, 52),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.textSecondary),
      ),
    );
  }

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'aroraTheme': '1.0',
        'id': id,
        'name': name,
        if (author != null) 'author': author,
        'dark': darkColors.toJson(),
        'light': lightColors.toJson(),
        'shapes': shapes.toJson(),
      };

  static AroraTheme fromJson(Map<String, dynamic> j) {
    final version = j['aroraTheme'] as String? ?? '1.0';
    if (!version.startsWith('1.')) {
      throw FormatException('Unsupported theme version: $version');
    }
    return AroraTheme(
      id: j['id'] as String,
      name: j['name'] as String,
      author: j['author'] as String?,
      darkColors: AroraColors.fromJson(j['dark'] as Map<String, dynamic>),
      lightColors: AroraColors.fromJson(j['light'] as Map<String, dynamic>),
      shapes: j['shapes'] != null
          ? AroraShapes.fromJson(j['shapes'] as Map<String, dynamic>)
          : const AroraShapes(),
    );
  }

  // ── ThemeExtension ────────────────────────────────────────────────────────

  @override
  AroraTheme copyWith({
    String? id,
    String? name,
    String? author,
    AroraColors? darkColors,
    AroraColors? lightColors,
    AroraShapes? shapes,
  }) =>
      AroraTheme(
        id: id ?? this.id,
        name: name ?? this.name,
        author: author ?? this.author,
        darkColors: darkColors ?? this.darkColors,
        lightColors: lightColors ?? this.lightColors,
        shapes: shapes ?? this.shapes,
      );

  @override
  AroraTheme lerp(AroraTheme? other, double t) {
    if (other == null) return this;
    return AroraTheme(
      id: t < 0.5 ? id : other.id,
      name: t < 0.5 ? name : other.name,
      author: t < 0.5 ? author : other.author,
      darkColors: darkColors.lerp(other.darkColors, t),
      lightColors: lightColors.lerp(other.lightColors, t),
      shapes: shapes.lerp(other.shapes, t),
    );
  }
}
