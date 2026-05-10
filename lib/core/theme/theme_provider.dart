import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arora/domain/entities/settings.dart';
import 'package:arora/services/settings_service.dart';

part 'theme_provider.g.dart';

class AppTheme {
  final ThemeData light;
  final ThemeData dark;
  final ThemeMode mode;

  AppTheme({required this.light, required this.dark, required this.mode});
}

@riverpod
AppTheme theme(Ref ref) {
  final settings = ref.watch(settingsServiceProvider);
  
  final seedColor = Color(settings.accentColorValue);
  
  final lightTheme = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  final darkTheme = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  ThemeMode mode;
  switch (settings.themeMode) {
    case AppThemeMode.light:
      mode = ThemeMode.light;
      break;
    case AppThemeMode.dark:
      mode = ThemeMode.dark;
      break;
    case AppThemeMode.system:
      mode = ThemeMode.system;
      break;
  }

  return AppTheme(light: lightTheme, dark: darkTheme, mode: mode);
}