// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves the active [AroraTheme] from [Settings.themeId].
///
/// Checks built-in themes first, then user-imported custom themes.
/// Falls back to [BuiltInThemes.dark] if the ID is not found.

@ProviderFor(activeAroraTheme)
final activeAroraThemeProvider = ActiveAroraThemeProvider._();

/// Resolves the active [AroraTheme] from [Settings.themeId].
///
/// Checks built-in themes first, then user-imported custom themes.
/// Falls back to [BuiltInThemes.dark] if the ID is not found.

final class ActiveAroraThemeProvider
    extends $FunctionalProvider<AroraTheme, AroraTheme, AroraTheme>
    with $Provider<AroraTheme> {
  /// Resolves the active [AroraTheme] from [Settings.themeId].
  ///
  /// Checks built-in themes first, then user-imported custom themes.
  /// Falls back to [BuiltInThemes.dark] if the ID is not found.
  ActiveAroraThemeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeAroraThemeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeAroraThemeHash();

  @$internal
  @override
  $ProviderElement<AroraTheme> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AroraTheme create(Ref ref) {
    return activeAroraTheme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AroraTheme value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AroraTheme>(value),
    );
  }
}

String _$activeAroraThemeHash() => r'0ca33061c8baa9335cf399e8c9352535e401157c';

/// Provides [AppTheme] consumed by [MaterialApp] in [app.dart].
///
/// Calls [AroraTheme.toMaterialTheme] for both brightness variants so
/// [MaterialApp.theme] / [MaterialApp.darkTheme] are always in sync with the
/// chosen [AroraTheme].

@ProviderFor(theme)
final themeProvider = ThemeProvider._();

/// Provides [AppTheme] consumed by [MaterialApp] in [app.dart].
///
/// Calls [AroraTheme.toMaterialTheme] for both brightness variants so
/// [MaterialApp.theme] / [MaterialApp.darkTheme] are always in sync with the
/// chosen [AroraTheme].

final class ThemeProvider
    extends $FunctionalProvider<AppTheme, AppTheme, AppTheme>
    with $Provider<AppTheme> {
  /// Provides [AppTheme] consumed by [MaterialApp] in [app.dart].
  ///
  /// Calls [AroraTheme.toMaterialTheme] for both brightness variants so
  /// [MaterialApp.theme] / [MaterialApp.darkTheme] are always in sync with the
  /// chosen [AroraTheme].
  ThemeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'themeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$themeHash();

  @$internal
  @override
  $ProviderElement<AppTheme> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppTheme create(Ref ref) {
    return theme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppTheme value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppTheme>(value),
    );
  }
}

String _$themeHash() => r'c7a85b646a1284f3209199e07101462e402b4e8f';
