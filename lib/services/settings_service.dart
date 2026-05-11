import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/core/theme/theme_importer.dart';
import 'package:arora/data/datasources/local/hive_database.dart';
import 'package:arora/domain/entities/settings.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_service.g.dart';

@Riverpod(keepAlive: true)
class SettingsService extends _$SettingsService {
  static const _settingsKey = 'user_settings';
  late final Box<Settings> _box;

  @override
  Settings build() {
    _box = Hive.box<Settings>(HiveDatabase.settingsBoxName);
    return _box.get(_settingsKey) ?? const Settings();
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    final updated = state.copyWith(themeMode: mode);
    state = updated;
    await _box.put(_settingsKey, updated);
  }

  /// Deprecated — accent color replaced by [AroraTheme] system. Kept for compat.
  Future<void> updateAccentColor(int colorValue) async {
    final updated = state.copyWith(accentColorValue: colorValue);
    state = updated;
    await _box.put(_settingsKey, updated);
  }

  /// Selects a built-in or imported theme by its [AroraTheme.id].
  Future<void> updateThemeId(String themeId) async {
    final updated = state.copyWith(themeId: themeId);
    state = updated;
    await _box.put(_settingsKey, updated);
  }

  /// Adds [theme] to the persisted custom theme list if its ID is not already present.
  Future<void> addCustomTheme(AroraTheme theme) async {
    final current = ThemeImporter.decodeList(state.customThemesJson);
    if (current.any((t) => t.id == theme.id)) return;
    final updated = state.copyWith(
      customThemesJson: ThemeImporter.encodeList([...current, theme]),
    );
    state = updated;
    await _box.put(_settingsKey, updated);
  }

  /// Removes the imported theme with the given [id].
  Future<void> removeCustomTheme(String id) async {
    final current = ThemeImporter.decodeList(state.customThemesJson);
    final filtered = current.where((t) => t.id != id).toList();
    final updated = state.copyWith(
      customThemesJson: ThemeImporter.encodeList(filtered),
    );
    state = updated;
    await _box.put(_settingsKey, updated);
  }

  /// All currently imported custom themes, decoded on the fly.
  List<AroraTheme> get customThemes =>
      ThemeImporter.decodeList(state.customThemesJson);
}
