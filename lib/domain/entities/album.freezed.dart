// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'album.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Album {
  /// Provider-specific album identifier.
  String get id;

  /// Album title.
  String get title;

  /// Primary artist name.
  String get artistName;

  /// URL to the album cover art.
  String? get thumbnailUrl;

  /// Year of release (e.g., `2024`).
  int? get releaseYear;

  /// Total number of tracks, if known.
  int? get trackCount;

  /// Track list — only populated after [getAlbumDetails] is called.
  List<Song> get songs;

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AlbumCopyWith<Album> get copyWith =>
      _$AlbumCopyWithImpl<Album>(this as Album, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Album &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.releaseYear, releaseYear) ||
                other.releaseYear == releaseYear) &&
            (identical(other.trackCount, trackCount) ||
                other.trackCount == trackCount) &&
            const DeepCollectionEquality().equals(other.songs, songs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      artistName,
      thumbnailUrl,
      releaseYear,
      trackCount,
      const DeepCollectionEquality().hash(songs));

  @override
  String toString() {
    return 'Album(id: $id, title: $title, artistName: $artistName, thumbnailUrl: $thumbnailUrl, releaseYear: $releaseYear, trackCount: $trackCount, songs: $songs)';
  }
}

/// @nodoc
abstract mixin class $AlbumCopyWith<$Res> {
  factory $AlbumCopyWith(Album value, $Res Function(Album) _then) =
      _$AlbumCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      String artistName,
      String? thumbnailUrl,
      int? releaseYear,
      int? trackCount,
      List<Song> songs});
}

/// @nodoc
class _$AlbumCopyWithImpl<$Res> implements $AlbumCopyWith<$Res> {
  _$AlbumCopyWithImpl(this._self, this._then);

  final Album _self;
  final $Res Function(Album) _then;

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artistName = null,
    Object? thumbnailUrl = freezed,
    Object? releaseYear = freezed,
    Object? trackCount = freezed,
    Object? songs = null,
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
      artistName: null == artistName
          ? _self.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseYear: freezed == releaseYear
          ? _self.releaseYear
          : releaseYear // ignore: cast_nullable_to_non_nullable
              as int?,
      trackCount: freezed == trackCount
          ? _self.trackCount
          : trackCount // ignore: cast_nullable_to_non_nullable
              as int?,
      songs: null == songs
          ? _self.songs
          : songs // ignore: cast_nullable_to_non_nullable
              as List<Song>,
    ));
  }
}

/// Adds pattern-matching-related methods to [Album].
extension AlbumPatterns on Album {
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
    TResult Function(_Album value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Album() when $default != null:
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
    TResult Function(_Album value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Album():
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
    TResult? Function(_Album value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Album() when $default != null:
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
            String id,
            String title,
            String artistName,
            String? thumbnailUrl,
            int? releaseYear,
            int? trackCount,
            List<Song> songs)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Album() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.artistName,
            _that.thumbnailUrl,
            _that.releaseYear,
            _that.trackCount,
            _that.songs);
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
            String id,
            String title,
            String artistName,
            String? thumbnailUrl,
            int? releaseYear,
            int? trackCount,
            List<Song> songs)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Album():
        return $default(
            _that.id,
            _that.title,
            _that.artistName,
            _that.thumbnailUrl,
            _that.releaseYear,
            _that.trackCount,
            _that.songs);
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
            String id,
            String title,
            String artistName,
            String? thumbnailUrl,
            int? releaseYear,
            int? trackCount,
            List<Song> songs)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Album() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.artistName,
            _that.thumbnailUrl,
            _that.releaseYear,
            _that.trackCount,
            _that.songs);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Album implements Album {
  const _Album(
      {required this.id,
      required this.title,
      required this.artistName,
      this.thumbnailUrl,
      this.releaseYear,
      this.trackCount,
      final List<Song> songs = const []})
      : _songs = songs;

  /// Provider-specific album identifier.
  @override
  final String id;

  /// Album title.
  @override
  final String title;

  /// Primary artist name.
  @override
  final String artistName;

  /// URL to the album cover art.
  @override
  final String? thumbnailUrl;

  /// Year of release (e.g., `2024`).
  @override
  final int? releaseYear;

  /// Total number of tracks, if known.
  @override
  final int? trackCount;

  /// Track list — only populated after [getAlbumDetails] is called.
  final List<Song> _songs;

  /// Track list — only populated after [getAlbumDetails] is called.
  @override
  @JsonKey()
  List<Song> get songs {
    if (_songs is EqualUnmodifiableListView) return _songs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_songs);
  }

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AlbumCopyWith<_Album> get copyWith =>
      __$AlbumCopyWithImpl<_Album>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Album &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.releaseYear, releaseYear) ||
                other.releaseYear == releaseYear) &&
            (identical(other.trackCount, trackCount) ||
                other.trackCount == trackCount) &&
            const DeepCollectionEquality().equals(other._songs, _songs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      artistName,
      thumbnailUrl,
      releaseYear,
      trackCount,
      const DeepCollectionEquality().hash(_songs));

  @override
  String toString() {
    return 'Album(id: $id, title: $title, artistName: $artistName, thumbnailUrl: $thumbnailUrl, releaseYear: $releaseYear, trackCount: $trackCount, songs: $songs)';
  }
}

/// @nodoc
abstract mixin class _$AlbumCopyWith<$Res> implements $AlbumCopyWith<$Res> {
  factory _$AlbumCopyWith(_Album value, $Res Function(_Album) _then) =
      __$AlbumCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String artistName,
      String? thumbnailUrl,
      int? releaseYear,
      int? trackCount,
      List<Song> songs});
}

/// @nodoc
class __$AlbumCopyWithImpl<$Res> implements _$AlbumCopyWith<$Res> {
  __$AlbumCopyWithImpl(this._self, this._then);

  final _Album _self;
  final $Res Function(_Album) _then;

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artistName = null,
    Object? thumbnailUrl = freezed,
    Object? releaseYear = freezed,
    Object? trackCount = freezed,
    Object? songs = null,
  }) {
    return _then(_Album(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _self.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseYear: freezed == releaseYear
          ? _self.releaseYear
          : releaseYear // ignore: cast_nullable_to_non_nullable
              as int?,
      trackCount: freezed == trackCount
          ? _self.trackCount
          : trackCount // ignore: cast_nullable_to_non_nullable
              as int?,
      songs: null == songs
          ? _self._songs
          : songs // ignore: cast_nullable_to_non_nullable
              as List<Song>,
    ));
  }
}

// dart format on
