// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Settings {
  /// Light / dark / system mode.
  @HiveField(0)
  AppThemeMode get themeMode;

  /// Legacy accent color int — kept for binary compat, no longer shown in UI.
  @HiveField(1)
  int get accentColorValue;

  /// ID of the active [AroraTheme]. Defaults to the built-in dark theme.
  @HiveField(2)
  String get themeId;

  /// JSON-encoded list of user-imported [AroraTheme] objects.
  @HiveField(3)
  String get customThemesJson;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SettingsCopyWith<Settings> get copyWith =>
      _$SettingsCopyWithImpl<Settings>(this as Settings, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Settings &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.accentColorValue, accentColorValue) ||
                other.accentColorValue == accentColorValue) &&
            (identical(other.themeId, themeId) || other.themeId == themeId) &&
            (identical(other.customThemesJson, customThemesJson) ||
                other.customThemesJson == customThemesJson));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, themeMode, accentColorValue, themeId, customThemesJson);

  @override
  String toString() {
    return 'Settings(themeMode: $themeMode, accentColorValue: $accentColorValue, themeId: $themeId, customThemesJson: $customThemesJson)';
  }
}

/// @nodoc
abstract mixin class $SettingsCopyWith<$Res> {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) _then) =
      _$SettingsCopyWithImpl;
  @useResult
  $Res call(
      {@HiveField(0) AppThemeMode themeMode,
      @HiveField(1) int accentColorValue,
      @HiveField(2) String themeId,
      @HiveField(3) String customThemesJson});
}

/// @nodoc
class _$SettingsCopyWithImpl<$Res> implements $SettingsCopyWith<$Res> {
  _$SettingsCopyWithImpl(this._self, this._then);

  final Settings _self;
  final $Res Function(Settings) _then;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? accentColorValue = null,
    Object? themeId = null,
    Object? customThemesJson = null,
  }) {
    return _then(_self.copyWith(
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as AppThemeMode,
      accentColorValue: null == accentColorValue
          ? _self.accentColorValue
          : accentColorValue // ignore: cast_nullable_to_non_nullable
              as int,
      themeId: null == themeId
          ? _self.themeId
          : themeId // ignore: cast_nullable_to_non_nullable
              as String,
      customThemesJson: null == customThemesJson
          ? _self.customThemesJson
          : customThemesJson // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [Settings].
extension SettingsPatterns on Settings {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Settings value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Settings() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Settings value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Settings():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Settings value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Settings() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            @HiveField(0) AppThemeMode themeMode,
            @HiveField(1) int accentColorValue,
            @HiveField(2) String themeId,
            @HiveField(3) String customThemesJson)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Settings() when $default != null:
        return $default(_that.themeMode, _that.accentColorValue, _that.themeId,
            _that.customThemesJson);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            @HiveField(0) AppThemeMode themeMode,
            @HiveField(1) int accentColorValue,
            @HiveField(2) String themeId,
            @HiveField(3) String customThemesJson)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Settings():
        return $default(_that.themeMode, _that.accentColorValue, _that.themeId,
            _that.customThemesJson);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            @HiveField(0) AppThemeMode themeMode,
            @HiveField(1) int accentColorValue,
            @HiveField(2) String themeId,
            @HiveField(3) String customThemesJson)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Settings() when $default != null:
        return $default(_that.themeMode, _that.accentColorValue, _that.themeId,
            _that.customThemesJson);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Settings extends Settings {
  const _Settings(
      {@HiveField(0) this.themeMode = AppThemeMode.system,
      @HiveField(1) this.accentColorValue = 0xFF007ACC,
      @HiveField(2) this.themeId = 'arora_dark',
      @HiveField(3) this.customThemesJson = '[]'})
      : super._();

  /// Light / dark / system mode.
  @override
  @JsonKey()
  @HiveField(0)
  final AppThemeMode themeMode;

  /// Legacy accent color int — kept for binary compat, no longer shown in UI.
  @override
  @JsonKey()
  @HiveField(1)
  final int accentColorValue;

  /// ID of the active [AroraTheme]. Defaults to the built-in dark theme.
  @override
  @JsonKey()
  @HiveField(2)
  final String themeId;

  /// JSON-encoded list of user-imported [AroraTheme] objects.
  @override
  @JsonKey()
  @HiveField(3)
  final String customThemesJson;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SettingsCopyWith<_Settings> get copyWith =>
      __$SettingsCopyWithImpl<_Settings>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Settings &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.accentColorValue, accentColorValue) ||
                other.accentColorValue == accentColorValue) &&
            (identical(other.themeId, themeId) || other.themeId == themeId) &&
            (identical(other.customThemesJson, customThemesJson) ||
                other.customThemesJson == customThemesJson));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, themeMode, accentColorValue, themeId, customThemesJson);

  @override
  String toString() {
    return 'Settings(themeMode: $themeMode, accentColorValue: $accentColorValue, themeId: $themeId, customThemesJson: $customThemesJson)';
  }
}

/// @nodoc
abstract mixin class _$SettingsCopyWith<$Res>
    implements $SettingsCopyWith<$Res> {
  factory _$SettingsCopyWith(_Settings value, $Res Function(_Settings) _then) =
      __$SettingsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@HiveField(0) AppThemeMode themeMode,
      @HiveField(1) int accentColorValue,
      @HiveField(2) String themeId,
      @HiveField(3) String customThemesJson});
}

/// @nodoc
class __$SettingsCopyWithImpl<$Res> implements _$SettingsCopyWith<$Res> {
  __$SettingsCopyWithImpl(this._self, this._then);

  final _Settings _self;
  final $Res Function(_Settings) _then;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? themeMode = null,
    Object? accentColorValue = null,
    Object? themeId = null,
    Object? customThemesJson = null,
  }) {
    return _then(_Settings(
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as AppThemeMode,
      accentColorValue: null == accentColorValue
          ? _self.accentColorValue
          : accentColorValue // ignore: cast_nullable_to_non_nullable
              as int,
      themeId: null == themeId
          ? _self.themeId
          : themeId // ignore: cast_nullable_to_non_nullable
              as String,
      customThemesJson: null == customThemesJson
          ? _self.customThemesJson
          : customThemesJson // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
