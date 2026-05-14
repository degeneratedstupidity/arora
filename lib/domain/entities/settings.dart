import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@HiveType(typeId: 2, adapterName: 'AppThemeModeAdapter')
enum AppThemeMode {
  @HiveField(0)
  system,
  @HiveField(1)
  light,
  @HiveField(2)
  dark,
}

/// User-configurable app settings persisted to Hive.
///
/// ## Theme system
/// [themeId] identifies which [AroraTheme] is active (built-in or imported).
/// [themeMode] controls whether the dark or light variant of that theme is shown.
/// [customThemesJson] stores all imported themes as a JSON-encoded list.
///
/// ## Field index rules
/// Never reuse a retired [HiveField] index — Hive uses them as stable binary
/// keys. New fields always get the next unused integer.
@freezed
@HiveType(typeId: 3, adapterName: 'SettingsAdapter')
abstract class Settings with _$Settings {
  const factory Settings({
    /// Light / dark / system mode.
    @HiveField(0) @Default(AppThemeMode.system) AppThemeMode themeMode,

    /// Legacy accent color int — kept for binary compat, no longer shown in UI.
    @HiveField(1) @Default(0xFF007ACC) int accentColorValue,

    /// ID of the active [AroraTheme]. Defaults to the built-in dark theme.
    @HiveField(2) @Default('arora_dark') String themeId,

    /// JSON-encoded list of user-imported [AroraTheme] objects.
    @HiveField(3) @Default('[]') String customThemesJson,
  }) = _Settings;

  const Settings._();
}
