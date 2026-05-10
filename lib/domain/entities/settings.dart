import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@HiveType(typeId: 2, adapterName: 'AppThemeModeAdapter')
enum AppThemeMode {
  @HiveField(0) system,
  @HiveField(1) light,
  @HiveField(2) dark,
}

/// Represents user-configurable app settings.
@freezed
@HiveType(typeId: 3, adapterName: 'SettingsAdapter')
abstract class Settings with _$Settings {
  const factory Settings({
    /// User's preferred theme mode (defaults to system).
    @HiveField(0) @Default(AppThemeMode.system) AppThemeMode themeMode,

    /// Primary accent color as an integer (defaults to a vivid blue: 0xFF007ACC).
    @HiveField(1) @Default(0xFF007ACC) int accentColorValue,
  }) = _Settings;

  // Added for Freezed 3.x custom method support if needed
  const Settings._();
}