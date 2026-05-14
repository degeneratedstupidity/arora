// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lyrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LyricLine {
  /// Offset in milliseconds from track start for this line.
  int get startMs;

  /// The text content of this line.
  String get text;

  /// Create a copy of LyricLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LyricLineCopyWith<LyricLine> get copyWith =>
      _$LyricLineCopyWithImpl<LyricLine>(this as LyricLine, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LyricLine &&
            (identical(other.startMs, startMs) || other.startMs == startMs) &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, startMs, text);

  @override
  String toString() {
    return 'LyricLine(startMs: $startMs, text: $text)';
  }
}

/// @nodoc
abstract mixin class $LyricLineCopyWith<$Res> {
  factory $LyricLineCopyWith(LyricLine value, $Res Function(LyricLine) _then) =
      _$LyricLineCopyWithImpl;
  @useResult
  $Res call({int startMs, String text});
}

/// @nodoc
class _$LyricLineCopyWithImpl<$Res> implements $LyricLineCopyWith<$Res> {
  _$LyricLineCopyWithImpl(this._self, this._then);

  final LyricLine _self;
  final $Res Function(LyricLine) _then;

  /// Create a copy of LyricLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startMs = null,
    Object? text = null,
  }) {
    return _then(_self.copyWith(
      startMs: null == startMs
          ? _self.startMs
          : startMs // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [LyricLine].
extension LyricLinePatterns on LyricLine {
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
    TResult Function(_LyricLine value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LyricLine() when $default != null:
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
    TResult Function(_LyricLine value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LyricLine():
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
    TResult? Function(_LyricLine value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LyricLine() when $default != null:
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
    TResult Function(int startMs, String text)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LyricLine() when $default != null:
        return $default(_that.startMs, _that.text);
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
    TResult Function(int startMs, String text) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LyricLine():
        return $default(_that.startMs, _that.text);
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
    TResult? Function(int startMs, String text)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LyricLine() when $default != null:
        return $default(_that.startMs, _that.text);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LyricLine implements LyricLine {
  const _LyricLine({required this.startMs, required this.text});

  /// Offset in milliseconds from track start for this line.
  @override
  final int startMs;

  /// The text content of this line.
  @override
  final String text;

  /// Create a copy of LyricLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LyricLineCopyWith<_LyricLine> get copyWith =>
      __$LyricLineCopyWithImpl<_LyricLine>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LyricLine &&
            (identical(other.startMs, startMs) || other.startMs == startMs) &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, startMs, text);

  @override
  String toString() {
    return 'LyricLine(startMs: $startMs, text: $text)';
  }
}

/// @nodoc
abstract mixin class _$LyricLineCopyWith<$Res>
    implements $LyricLineCopyWith<$Res> {
  factory _$LyricLineCopyWith(
          _LyricLine value, $Res Function(_LyricLine) _then) =
      __$LyricLineCopyWithImpl;
  @override
  @useResult
  $Res call({int startMs, String text});
}

/// @nodoc
class __$LyricLineCopyWithImpl<$Res> implements _$LyricLineCopyWith<$Res> {
  __$LyricLineCopyWithImpl(this._self, this._then);

  final _LyricLine _self;
  final $Res Function(_LyricLine) _then;

  /// Create a copy of LyricLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? startMs = null,
    Object? text = null,
  }) {
    return _then(_LyricLine(
      startMs: null == startMs
          ? _self.startMs
          : startMs // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$Lyrics {
  /// Ordered list of timed lyric lines (LRC format).
  /// Empty when only plain text is available.
  List<LyricLine> get timedLines;

  /// Full lyrics as a plain text string.
  /// Used when timed lines are unavailable.
  String? get plainText;

  /// The language of the lyrics (ISO 639-1 code, e.g., `'en'`, `'hi'`).
  String? get language;

  /// Create a copy of Lyrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LyricsCopyWith<Lyrics> get copyWith =>
      _$LyricsCopyWithImpl<Lyrics>(this as Lyrics, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Lyrics &&
            const DeepCollectionEquality()
                .equals(other.timedLines, timedLines) &&
            (identical(other.plainText, plainText) ||
                other.plainText == plainText) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(timedLines), plainText, language);

  @override
  String toString() {
    return 'Lyrics(timedLines: $timedLines, plainText: $plainText, language: $language)';
  }
}

/// @nodoc
abstract mixin class $LyricsCopyWith<$Res> {
  factory $LyricsCopyWith(Lyrics value, $Res Function(Lyrics) _then) =
      _$LyricsCopyWithImpl;
  @useResult
  $Res call({List<LyricLine> timedLines, String? plainText, String? language});
}

/// @nodoc
class _$LyricsCopyWithImpl<$Res> implements $LyricsCopyWith<$Res> {
  _$LyricsCopyWithImpl(this._self, this._then);

  final Lyrics _self;
  final $Res Function(Lyrics) _then;

  /// Create a copy of Lyrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timedLines = null,
    Object? plainText = freezed,
    Object? language = freezed,
  }) {
    return _then(_self.copyWith(
      timedLines: null == timedLines
          ? _self.timedLines
          : timedLines // ignore: cast_nullable_to_non_nullable
              as List<LyricLine>,
      plainText: freezed == plainText
          ? _self.plainText
          : plainText // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Lyrics].
extension LyricsPatterns on Lyrics {
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
    TResult Function(_Lyrics value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Lyrics() when $default != null:
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
    TResult Function(_Lyrics value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Lyrics():
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
    TResult? Function(_Lyrics value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Lyrics() when $default != null:
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
            List<LyricLine> timedLines, String? plainText, String? language)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Lyrics() when $default != null:
        return $default(_that.timedLines, _that.plainText, _that.language);
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
            List<LyricLine> timedLines, String? plainText, String? language)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Lyrics():
        return $default(_that.timedLines, _that.plainText, _that.language);
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
            List<LyricLine> timedLines, String? plainText, String? language)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Lyrics() when $default != null:
        return $default(_that.timedLines, _that.plainText, _that.language);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Lyrics extends Lyrics {
  const _Lyrics(
      {final List<LyricLine> timedLines = const [],
      this.plainText,
      this.language})
      : _timedLines = timedLines,
        super._();

  /// Ordered list of timed lyric lines (LRC format).
  /// Empty when only plain text is available.
  final List<LyricLine> _timedLines;

  /// Ordered list of timed lyric lines (LRC format).
  /// Empty when only plain text is available.
  @override
  @JsonKey()
  List<LyricLine> get timedLines {
    if (_timedLines is EqualUnmodifiableListView) return _timedLines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timedLines);
  }

  /// Full lyrics as a plain text string.
  /// Used when timed lines are unavailable.
  @override
  final String? plainText;

  /// The language of the lyrics (ISO 639-1 code, e.g., `'en'`, `'hi'`).
  @override
  final String? language;

  /// Create a copy of Lyrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LyricsCopyWith<_Lyrics> get copyWith =>
      __$LyricsCopyWithImpl<_Lyrics>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Lyrics &&
            const DeepCollectionEquality()
                .equals(other._timedLines, _timedLines) &&
            (identical(other.plainText, plainText) ||
                other.plainText == plainText) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_timedLines), plainText, language);

  @override
  String toString() {
    return 'Lyrics(timedLines: $timedLines, plainText: $plainText, language: $language)';
  }
}

/// @nodoc
abstract mixin class _$LyricsCopyWith<$Res> implements $LyricsCopyWith<$Res> {
  factory _$LyricsCopyWith(_Lyrics value, $Res Function(_Lyrics) _then) =
      __$LyricsCopyWithImpl;
  @override
  @useResult
  $Res call({List<LyricLine> timedLines, String? plainText, String? language});
}

/// @nodoc
class __$LyricsCopyWithImpl<$Res> implements _$LyricsCopyWith<$Res> {
  __$LyricsCopyWithImpl(this._self, this._then);

  final _Lyrics _self;
  final $Res Function(_Lyrics) _then;

  /// Create a copy of Lyrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? timedLines = null,
    Object? plainText = freezed,
    Object? language = freezed,
  }) {
    return _then(_Lyrics(
      timedLines: null == timedLines
          ? _self._timedLines
          : timedLines // ignore: cast_nullable_to_non_nullable
              as List<LyricLine>,
      plainText: freezed == plainText
          ? _self.plainText
          : plainText // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
