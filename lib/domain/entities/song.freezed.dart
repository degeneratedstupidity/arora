// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Song {
  /// Unique identifier (provider-specific, e.g., YouTube video ID).
  @HiveField(0)
  String get id;

  /// Track title as returned by the provider.
  @HiveField(1)
  String get title;

  /// Primary artist name (display string).
  @HiveField(2)
  String get artistName;

  /// Album or single name. Null if not available.
  @HiveField(3)
  String? get albumName;

  /// URL to the best-quality thumbnail / album art image.
  @HiveField(4)
  String? get thumbnailUrl;

  /// Track duration in milliseconds. Null if unknown before streaming.
  @HiveField(5)
  int?
      get durationMs; // ── Music Video ──────────────────────────────────────────────────────
  /// Whether this track has an associated music video.
  ///
  /// When true, the Now Playing screen shows an Audio/Video toggle.
  @HiveField(6)
  bool get hasVideo;

  /// The video ID used to resolve the music video stream URL.
  ///
  /// For the YouTube provider this is the same as [id].
  /// For other providers this may differ or be null when [hasVideo] is false.
  @HiveField(7)
  String?
      get videoId; // ── Offline / Download ───────────────────────────────────────────────
  /// Whether this track has been downloaded for offline playback.
  @HiveField(8)
  bool get isDownloaded;

  /// Absolute path to the locally cached audio file.
  /// Null when the track has not been downloaded.
  @HiveField(9)
  String?
      get localFilePath; // ── Metadata ────────────────────────────────────────────────────────
  /// ISO 8601 date string of when the track was released, if known.
  @HiveField(10)
  String? get releaseDate;

  /// Number of times this track has been played in the current session.
  @HiveField(11)
  int get playCount;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SongCopyWith<Song> get copyWith =>
      _$SongCopyWithImpl<Song>(this as Song, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Song &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.albumName, albumName) ||
                other.albumName == albumName) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            (identical(other.hasVideo, hasVideo) ||
                other.hasVideo == hasVideo) &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.isDownloaded, isDownloaded) ||
                other.isDownloaded == isDownloaded) &&
            (identical(other.localFilePath, localFilePath) ||
                other.localFilePath == localFilePath) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            (identical(other.playCount, playCount) ||
                other.playCount == playCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      artistName,
      albumName,
      thumbnailUrl,
      durationMs,
      hasVideo,
      videoId,
      isDownloaded,
      localFilePath,
      releaseDate,
      playCount);

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artistName: $artistName, albumName: $albumName, thumbnailUrl: $thumbnailUrl, durationMs: $durationMs, hasVideo: $hasVideo, videoId: $videoId, isDownloaded: $isDownloaded, localFilePath: $localFilePath, releaseDate: $releaseDate, playCount: $playCount)';
  }
}

/// @nodoc
abstract mixin class $SongCopyWith<$Res> {
  factory $SongCopyWith(Song value, $Res Function(Song) _then) =
      _$SongCopyWithImpl;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) String artistName,
      @HiveField(3) String? albumName,
      @HiveField(4) String? thumbnailUrl,
      @HiveField(5) int? durationMs,
      @HiveField(6) bool hasVideo,
      @HiveField(7) String? videoId,
      @HiveField(8) bool isDownloaded,
      @HiveField(9) String? localFilePath,
      @HiveField(10) String? releaseDate,
      @HiveField(11) int playCount});
}

/// @nodoc
class _$SongCopyWithImpl<$Res> implements $SongCopyWith<$Res> {
  _$SongCopyWithImpl(this._self, this._then);

  final Song _self;
  final $Res Function(Song) _then;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artistName = null,
    Object? albumName = freezed,
    Object? thumbnailUrl = freezed,
    Object? durationMs = freezed,
    Object? hasVideo = null,
    Object? videoId = freezed,
    Object? isDownloaded = null,
    Object? localFilePath = freezed,
    Object? releaseDate = freezed,
    Object? playCount = null,
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
      albumName: freezed == albumName
          ? _self.albumName
          : albumName // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMs: freezed == durationMs
          ? _self.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      hasVideo: null == hasVideo
          ? _self.hasVideo
          : hasVideo // ignore: cast_nullable_to_non_nullable
              as bool,
      videoId: freezed == videoId
          ? _self.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String?,
      isDownloaded: null == isDownloaded
          ? _self.isDownloaded
          : isDownloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      localFilePath: freezed == localFilePath
          ? _self.localFilePath
          : localFilePath // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseDate: freezed == releaseDate
          ? _self.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as String?,
      playCount: null == playCount
          ? _self.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [Song].
extension SongPatterns on Song {
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
    TResult Function(_Song value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Song() when $default != null:
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
    TResult Function(_Song value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Song():
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
    TResult? Function(_Song value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Song() when $default != null:
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
            @HiveField(2) String artistName,
            @HiveField(3) String? albumName,
            @HiveField(4) String? thumbnailUrl,
            @HiveField(5) int? durationMs,
            @HiveField(6) bool hasVideo,
            @HiveField(7) String? videoId,
            @HiveField(8) bool isDownloaded,
            @HiveField(9) String? localFilePath,
            @HiveField(10) String? releaseDate,
            @HiveField(11) int playCount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Song() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.artistName,
            _that.albumName,
            _that.thumbnailUrl,
            _that.durationMs,
            _that.hasVideo,
            _that.videoId,
            _that.isDownloaded,
            _that.localFilePath,
            _that.releaseDate,
            _that.playCount);
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
            @HiveField(2) String artistName,
            @HiveField(3) String? albumName,
            @HiveField(4) String? thumbnailUrl,
            @HiveField(5) int? durationMs,
            @HiveField(6) bool hasVideo,
            @HiveField(7) String? videoId,
            @HiveField(8) bool isDownloaded,
            @HiveField(9) String? localFilePath,
            @HiveField(10) String? releaseDate,
            @HiveField(11) int playCount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Song():
        return $default(
            _that.id,
            _that.title,
            _that.artistName,
            _that.albumName,
            _that.thumbnailUrl,
            _that.durationMs,
            _that.hasVideo,
            _that.videoId,
            _that.isDownloaded,
            _that.localFilePath,
            _that.releaseDate,
            _that.playCount);
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
            @HiveField(2) String artistName,
            @HiveField(3) String? albumName,
            @HiveField(4) String? thumbnailUrl,
            @HiveField(5) int? durationMs,
            @HiveField(6) bool hasVideo,
            @HiveField(7) String? videoId,
            @HiveField(8) bool isDownloaded,
            @HiveField(9) String? localFilePath,
            @HiveField(10) String? releaseDate,
            @HiveField(11) int playCount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Song() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.artistName,
            _that.albumName,
            _that.thumbnailUrl,
            _that.durationMs,
            _that.hasVideo,
            _that.videoId,
            _that.isDownloaded,
            _that.localFilePath,
            _that.releaseDate,
            _that.playCount);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Song implements Song {
  const _Song(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.title,
      @HiveField(2) required this.artistName,
      @HiveField(3) this.albumName,
      @HiveField(4) this.thumbnailUrl,
      @HiveField(5) this.durationMs,
      @HiveField(6) this.hasVideo = false,
      @HiveField(7) this.videoId,
      @HiveField(8) this.isDownloaded = false,
      @HiveField(9) this.localFilePath,
      @HiveField(10) this.releaseDate,
      @HiveField(11) this.playCount = 0});

  /// Unique identifier (provider-specific, e.g., YouTube video ID).
  @override
  @HiveField(0)
  final String id;

  /// Track title as returned by the provider.
  @override
  @HiveField(1)
  final String title;

  /// Primary artist name (display string).
  @override
  @HiveField(2)
  final String artistName;

  /// Album or single name. Null if not available.
  @override
  @HiveField(3)
  final String? albumName;

  /// URL to the best-quality thumbnail / album art image.
  @override
  @HiveField(4)
  final String? thumbnailUrl;

  /// Track duration in milliseconds. Null if unknown before streaming.
  @override
  @HiveField(5)
  final int? durationMs;
// ── Music Video ──────────────────────────────────────────────────────
  /// Whether this track has an associated music video.
  ///
  /// When true, the Now Playing screen shows an Audio/Video toggle.
  @override
  @JsonKey()
  @HiveField(6)
  final bool hasVideo;

  /// The video ID used to resolve the music video stream URL.
  ///
  /// For the YouTube provider this is the same as [id].
  /// For other providers this may differ or be null when [hasVideo] is false.
  @override
  @HiveField(7)
  final String? videoId;
// ── Offline / Download ───────────────────────────────────────────────
  /// Whether this track has been downloaded for offline playback.
  @override
  @JsonKey()
  @HiveField(8)
  final bool isDownloaded;

  /// Absolute path to the locally cached audio file.
  /// Null when the track has not been downloaded.
  @override
  @HiveField(9)
  final String? localFilePath;
// ── Metadata ────────────────────────────────────────────────────────
  /// ISO 8601 date string of when the track was released, if known.
  @override
  @HiveField(10)
  final String? releaseDate;

  /// Number of times this track has been played in the current session.
  @override
  @JsonKey()
  @HiveField(11)
  final int playCount;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SongCopyWith<_Song> get copyWith =>
      __$SongCopyWithImpl<_Song>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Song &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.albumName, albumName) ||
                other.albumName == albumName) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            (identical(other.hasVideo, hasVideo) ||
                other.hasVideo == hasVideo) &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.isDownloaded, isDownloaded) ||
                other.isDownloaded == isDownloaded) &&
            (identical(other.localFilePath, localFilePath) ||
                other.localFilePath == localFilePath) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            (identical(other.playCount, playCount) ||
                other.playCount == playCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      artistName,
      albumName,
      thumbnailUrl,
      durationMs,
      hasVideo,
      videoId,
      isDownloaded,
      localFilePath,
      releaseDate,
      playCount);

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artistName: $artistName, albumName: $albumName, thumbnailUrl: $thumbnailUrl, durationMs: $durationMs, hasVideo: $hasVideo, videoId: $videoId, isDownloaded: $isDownloaded, localFilePath: $localFilePath, releaseDate: $releaseDate, playCount: $playCount)';
  }
}

/// @nodoc
abstract mixin class _$SongCopyWith<$Res> implements $SongCopyWith<$Res> {
  factory _$SongCopyWith(_Song value, $Res Function(_Song) _then) =
      __$SongCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) String artistName,
      @HiveField(3) String? albumName,
      @HiveField(4) String? thumbnailUrl,
      @HiveField(5) int? durationMs,
      @HiveField(6) bool hasVideo,
      @HiveField(7) String? videoId,
      @HiveField(8) bool isDownloaded,
      @HiveField(9) String? localFilePath,
      @HiveField(10) String? releaseDate,
      @HiveField(11) int playCount});
}

/// @nodoc
class __$SongCopyWithImpl<$Res> implements _$SongCopyWith<$Res> {
  __$SongCopyWithImpl(this._self, this._then);

  final _Song _self;
  final $Res Function(_Song) _then;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artistName = null,
    Object? albumName = freezed,
    Object? thumbnailUrl = freezed,
    Object? durationMs = freezed,
    Object? hasVideo = null,
    Object? videoId = freezed,
    Object? isDownloaded = null,
    Object? localFilePath = freezed,
    Object? releaseDate = freezed,
    Object? playCount = null,
  }) {
    return _then(_Song(
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
      albumName: freezed == albumName
          ? _self.albumName
          : albumName // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMs: freezed == durationMs
          ? _self.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      hasVideo: null == hasVideo
          ? _self.hasVideo
          : hasVideo // ignore: cast_nullable_to_non_nullable
              as bool,
      videoId: freezed == videoId
          ? _self.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String?,
      isDownloaded: null == isDownloaded
          ? _self.isDownloaded
          : isDownloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      localFilePath: freezed == localFilePath
          ? _self.localFilePath
          : localFilePath // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseDate: freezed == releaseDate
          ? _self.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as String?,
      playCount: null == playCount
          ? _self.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
