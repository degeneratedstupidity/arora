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
    // Return the saved settings, or the default object if none exist.
    return _box.get(_settingsKey) ?? const Settings();
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    final updated = state.copyWith(themeMode: mode);
    state = updated;
    await _box.put(_settingsKey, updated);
  }

  Future<void> updateAccentColor(int colorValue) async {
    final updated = state.copyWith(accentColorValue: colorValue);
    state = updated;
    await _box.put(_settingsKey, updated);
  }
}