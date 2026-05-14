// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Playlist {
  @HiveField(0)
  String get id;
  @HiveField(1)
  String get title;
  @HiveField(2)
  List<Song> get songs;
  @HiveField(3)
  String? get thumbnailUrl;

  /// Whether the user can edit this playlist (false for auto-generated like 'Favorites')
  @HiveField(4)
  bool get isEditable;

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlaylistCopyWith<Playlist> get copyWith =>
      _$PlaylistCopyWithImpl<Playlist>(this as Playlist, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Playlist &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other.songs, songs) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.isEditable, isEditable) ||
                other.isEditable == isEditable));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title,
      const DeepCollectionEquality().hash(songs), thumbnailUrl, isEditable);

  @override
  String toString() {
    return 'Playlist(id: $id, title: $title, songs: $songs, thumbnailUrl: $thumbnailUrl, isEditable: $isEditable)';
  }
}

/// @nodoc
abstract mixin class $PlaylistCopyWith<$Res> {
  factory $PlaylistCopyWith(Playlist value, $Res Function(Playlist) _then) =
      _$PlaylistCopyWithImpl;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) List<Song> songs,
      @HiveField(3) String? thumbnailUrl,
      @HiveField(4) bool isEditable});
}

/// @nodoc
class _$PlaylistCopyWithImpl<$Res> implements $PlaylistCopyWith<$Res> {
  _$PlaylistCopyWithImpl(this._self, this._then);

  final Playlist _self;
  final $Res Function(Playlist) _then;

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? songs = null,
    Object? thumbnailUrl = freezed,
    Object? isEditable = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      songs: null == songs
          ? _self.songs
          : songs // ignore: cast_nullable_to_non_nullable
              as List<Song>,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isEditable: null == isEditable
          ? _self.isEditable
          : isEditable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [Playlist].
extension PlaylistPatterns on Playlist {
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
    TResult Function(_Playlist value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Playlist() when $default != null:
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
    TResult Function(_Playlist value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Playlist():
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
    TResult? Function(_Playlist value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Playlist() when $default != null:
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
            @HiveField(0) String id,
            @HiveField(1) String title,
            @HiveField(2) List<Song> songs,
            @HiveField(3) String? thumbnailUrl,
            @HiveField(4) bool isEditable)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Playlist() when $default != null:
        return $default(_that.id, _that.title, _that.songs, _that.thumbnailUrl,
            _that.isEditable);
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
            @HiveField(0) String id,
            @HiveField(1) String title,
            @HiveField(2) List<Song> songs,
            @HiveField(3) String? thumbnailUrl,
            @HiveField(4) bool isEditable)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Playlist():
        return $default(_that.id, _that.title, _that.songs, _that.thumbnailUrl,
            _that.isEditable);
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
            @HiveField(0) String id,
            @HiveField(1) String title,
            @HiveField(2) List<Song> songs,
            @HiveField(3) String? thumbnailUrl,
            @HiveField(4) bool isEditable)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Playlist() when $default != null:
        return $default(_that.id, _that.title, _that.songs, _that.thumbnailUrl,
            _that.isEditable);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Playlist implements Playlist {
  const _Playlist(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.title,
      @HiveField(2) final List<Song> songs = const [],
      @HiveField(3) this.thumbnailUrl,
      @HiveField(4) this.isEditable = true})
      : _songs = songs;

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String title;
  final List<Song> _songs;
  @override
  @JsonKey()
  @HiveField(2)
  List<Song> get songs {
    if (_songs is EqualUnmodifiableListView) return _songs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_songs);
  }

  @override
  @HiveField(3)
  final String? thumbnailUrl;

  /// Whether the user can edit this playlist (false for auto-generated like 'Favorites')
  @override
  @JsonKey()
  @HiveField(4)
  final bool isEditable;

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PlaylistCopyWith<_Playlist> get copyWith =>
      __$PlaylistCopyWithImpl<_Playlist>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Playlist &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._songs, _songs) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.isEditable, isEditable) ||
                other.isEditable == isEditable));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title,
      const DeepCollectionEquality().hash(_songs), thumbnailUrl, isEditable);

  @override
  String toString() {
    return 'Playlist(id: $id, title: $title, songs: $songs, thumbnailUrl: $thumbnailUrl, isEditable: $isEditable)';
  }
}

/// @nodoc
abstract mixin class _$PlaylistCopyWith<$Res>
    implements $PlaylistCopyWith<$Res> {
  factory _$PlaylistCopyWith(_Playlist value, $Res Function(_Playlist) _then) =
      __$PlaylistCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) List<Song> songs,
      @HiveField(3) String? thumbnailUrl,
      @HiveField(4) bool isEditable});
}

/// @nodoc
class __$PlaylistCopyWithImpl<$Res> implements _$PlaylistCopyWith<$Res> {
  __$PlaylistCopyWithImpl(this._self, this._then);

  final _Playlist _self;
  final $Res Function(_Playlist) _then;

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? songs = null,
    Object? thumbnailUrl = freezed,
    Object? isEditable = null,
  }) {
    return _then(_Playlist(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      songs: null == songs
          ? _self._songs
          : songs // ignore: cast_nullable_to_non_nullable
              as List<Song>,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isEditable: null == isEditable
          ? _self.isEditable
          : isEditable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
