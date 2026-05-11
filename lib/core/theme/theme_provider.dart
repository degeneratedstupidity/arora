import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/core/theme/built_in_themes.dart';
import 'package:arora/core/theme/theme_importer.dart';
import 'package:arora/domain/entities/settings.dart';
import 'package:arora/services/settings_service.dart';

part 'theme_provider.g.dart';

/// Carries [ThemeData] for both brightnesses + the active [ThemeMode].
/// Consumed by [MaterialApp] in [app.dart] — shape does not change.
class AppTheme {
  AppTheme({required this.light, required this.dark, required this.mode});
  final ThemeData light;
  final ThemeData dark;
  final ThemeMode mode;
}

/// Resolves the active [AroraTheme] from [Settings.themeId].
///
/// Checks built-in themes first, then user-imported custom themes.
/// Falls back to [BuiltInThemes.dark] if the ID is not found.
@riverpod
AroraTheme activeAroraTheme(Ref ref) {
  final settings = ref.watch(settingsServiceProvider);
  final id = settings.themeId;

  // 1. Built-in themes
  final builtIn = BuiltInThemes.all.where((t) => t.id == id).firstOrNull;
  if (builtIn != null) return builtIn;

  // 2. User-imported themes
  final customs = ThemeImporter.decodeList(settings.customThemesJson);
  final custom = customs.where((t) => t.id == id).firstOrNull;
  if (custom != null) return custom;

  return BuiltInThemes.dark;
}

/// Provides [AppTheme] consumed by [MaterialApp] in [app.dart].
///
/// Calls [AroraTheme.toMaterialTheme] for both brightness variants so
/// [MaterialApp.theme] / [MaterialApp.darkTheme] are always in sync with the
/// chosen [AroraTheme].
@riverpod
AppTheme theme(Ref ref) {
  final aroraTheme = ref.watch(activeAroraThemeProvider);
  final settings = ref.watch(settingsServiceProvider);

  final ThemeMode mode = switch (settings.themeMode) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };

  return AppTheme(
    light: aroraTheme.toMaterialTheme(Brightness.light),
    dark: aroraTheme.toMaterialTheme(Brightness.dark),
    mode: mode,
  );
}
