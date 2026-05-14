library;

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:arora/core/theme/arora_theme.dart';

/// Handles importing and exporting [AroraTheme] files.
///
/// ## Theme file format
/// A `.arora-theme` file is plain UTF-8 JSON. See [AroraTheme.toJson] for
/// the schema. Theme authors can create these by hand or by exporting an
/// existing built-in and modifying it.
///
/// ## Sharing themes
/// Themes are single self-contained JSON files — easy to share via GitHub
/// Gist, Discord, or any file host. Users import via Settings → Themes →
/// Import Theme.
abstract final class ThemeImporter {
  /// Opens the OS file picker, parses the chosen file, and returns the theme.
  ///
  /// Returns `null` if the user cancels, the file is invalid JSON, or the
  /// JSON doesn't match the [AroraTheme] schema.
  static Future<({AroraTheme theme, String error})?>
      pickAndImport(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['arora-theme', 'json'],
        allowMultiple: false,
        dialogTitle: 'Import Arora Theme',
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.single;
      final String raw;

      if (file.bytes != null) {
        // Web / memory path
        raw = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        raw = await File(file.path!).readAsString();
      } else {
        return (theme: _placeholder, error: 'Could not read file.');
      }

      final json = jsonDecode(raw) as Map<String, dynamic>;
      final theme = AroraTheme.fromJson(json);
      return (theme: theme, error: '');
    } on FormatException catch (e) {
      return (theme: _placeholder, error: 'Invalid theme file: ${e.message}');
    } catch (e) {
      return (theme: _placeholder, error: 'Import failed: $e');
    }
  }

  /// Exports [theme] to the OS download directory (Linux) or shares it
  /// (Android). Returns the output path, or null on failure.
  static Future<String?> export(AroraTheme theme) async {
    try {
      final json = const JsonEncoder.withIndent('  ').convert(theme.toJson());
      final fileName = '${theme.id}.arora-theme';

      if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        final savePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Export Theme',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['arora-theme'],
        );
        if (savePath == null) return null;
        await File(savePath).writeAsString(json);
        return savePath;
      } else {
        // Android / iOS: write to temp dir, then let the OS share sheet handle it.
        final dir = Directory.systemTemp;
        final file = File('${dir.path}/$fileName');
        await file.writeAsString(json);
        return file.path;
      }
    } catch (_) {
      return null;
    }
  }

  /// Serializes a list of [AroraTheme] objects to a JSON string for Hive storage.
  static String encodeList(List<AroraTheme> themes) =>
      jsonEncode(themes.map((t) => t.toJson()).toList());

  /// Deserializes a Hive-stored JSON string back to [AroraTheme] objects.
  /// Skips any malformed entries rather than crashing.
  static List<AroraTheme> decodeList(String json) {
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map((j) {
            try {
              return AroraTheme.fromJson(j);
            } catch (_) {
              return null;
            }
          })
          .whereType<AroraTheme>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  static const _placeholder = AroraTheme(
    id: '__error__',
    name: '',
    darkColors: _emptyColors,
    lightColors: _emptyColors,
  );

  static const _emptyColors = AroraColors(
    background: Colors.black,
    surface: Colors.black,
    surfaceRaised: Colors.black,
    surfaceHighest: Colors.black,
    textPrimary: Colors.white,
    textSecondary: Colors.white,
    textTertiary: Colors.white,
    playButtonBg: Colors.white,
    playButtonFg: Colors.black,
    accent: Colors.white,
  );
}
