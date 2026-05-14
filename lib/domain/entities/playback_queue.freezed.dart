// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_queue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaybackQueue {
  List<Song> get songs;
  int get currentIndex;
  bool get isSmartShuffleEnabled;

  /// Create a copy of PlaybackQueue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlaybackQueueCopyWith<PlaybackQueue> get copyWith =>
      _$PlaybackQueueCopyWithImpl<PlaybackQueue>(
          this as PlaybackQueue, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PlaybackQueue &&
            const DeepCollectionEquality().equals(other.songs, songs) &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            (identical(other.isSmartShuffleEnabled, isSmartShuffleEnabled) ||
                other.isSmartShuffleEnabled == isSmartShuffleEnabled));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(songs),
      currentIndex,
      isSmartShuffleEnabled);

  @override
  String toString() {
    return 'PlaybackQueue(songs: $songs, currentIndex: $currentIndex, isSmartShuffleEnabled: $isSmartShuffleEnabled)';
  }
}

/// @nodoc
abstract mixin class $PlaybackQueueCopyWith<$Res> {
  factory $PlaybackQueueCopyWith(
          PlaybackQueue value, $Res Function(PlaybackQueue) _then) =
      _$PlaybackQueueCopyWithImpl;
  @useResult
  $Res call({List<Song> songs, int currentIndex, bool isSmartShuffleEnabled});
}

/// @nodoc
class _$PlaybackQueueCopyWithImpl<$Res>
    implements $PlaybackQueueCopyWith<$Res> {
  _$PlaybackQueueCopyWithImpl(this._self, this._then);

  final PlaybackQueue _self;
  final $Res Function(PlaybackQueue) _then;

  /// Create a copy of PlaybackQueue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? songs = null,
    Object? currentIndex = null,
    Object? isSmartShuffleEnabled = null,
  }) {
    return _then(_self.copyWith(
      songs: null == songs
          ? _self.songs
          : songs // ignore: cast_nullable_to_non_nullable
              as List<Song>,
      currentIndex: null == currentIndex
          ? _self.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isSmartShuffleEnabled: null == isSmartShuffleEnabled
          ? _self.isSmartShuffleEnabled
          : isSmartShuffleEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [PlaybackQueue].
extension PlaybackQueuePatterns on PlaybackQueue {
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
    TResult Function(_PlaybackQueue value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaybackQueue() when $default != null:
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
    TResult Function(_PlaybackQueue value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaybackQueue():
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
    TResult? Function(_PlaybackQueue value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaybackQueue() when $default != null:
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
            List<Song> songs, int currentIndex, bool isSmartShuffleEnabled)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaybackQueue() when $default != null:
        return $default(
            _that.songs, _that.currentIndex, _that.isSmartShuffleEnabled);
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
            List<Song> songs, int currentIndex, bool isSmartShuffleEnabled)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaybackQueue():
        return $default(
            _that.songs, _that.currentIndex, _that.isSmartShuffleEnabled);
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
            List<Song> songs, int currentIndex, bool isSmartShuffleEnabled)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaybackQueue() when $default != null:
        return $default(
            _that.songs, _that.currentIndex, _that.isSmartShuffleEnabled);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PlaybackQueue extends PlaybackQueue {
  const _PlaybackQueue(
      {final List<Song> songs = const [],
      this.currentIndex = 0,
      this.isSmartShuffleEnabled = false})
      : _songs = songs,
        super._();

  final List<Song> _songs;
  @override
  @JsonKey()
  List<Song> get songs {
    if (_songs is EqualUnmodifiableListView) return _songs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_songs);
  }

  @override
  @JsonKey()
  final int currentIndex;
  @override
  @JsonKey()
  final bool isSmartShuffleEnabled;

  /// Create a copy of PlaybackQueue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PlaybackQueueCopyWith<_PlaybackQueue> get copyWith =>
      __$PlaybackQueueCopyWithImpl<_PlaybackQueue>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PlaybackQueue &&
            const DeepCollectionEquality().equals(other._songs, _songs) &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            (identical(other.isSmartShuffleEnabled, isSmartShuffleEnabled) ||
                other.isSmartShuffleEnabled == isSmartShuffleEnabled));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_songs),
      currentIndex,
      isSmartShuffleEnabled);

  @override
  String toString() {
    return 'PlaybackQueue(songs: $songs, currentIndex: $currentIndex, isSmartShuffleEnabled: $isSmartShuffleEnabled)';
  }
}

/// @nodoc
abstract mixin class _$PlaybackQueueCopyWith<$Res>
    implements $PlaybackQueueCopyWith<$Res> {
  factory _$PlaybackQueueCopyWith(
          _PlaybackQueue value, $Res Function(_PlaybackQueue) _then) =
      __$PlaybackQueueCopyWithImpl;
  @override
  @useResult
  $Res call({List<Song> songs, int currentIndex, bool isSmartShuffleEnabled});
}

/// @nodoc
class __$PlaybackQueueCopyWithImpl<$Res>
    implements _$PlaybackQueueCopyWith<$Res> {
  __$PlaybackQueueCopyWithImpl(this._self, this._then);

  final _PlaybackQueue _self;
  final $Res Function(_PlaybackQueue) _then;

  /// Create a copy of PlaybackQueue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? songs = null,
    Object? currentIndex = null,
    Object? isSmartShuffleEnabled = null,
  }) {
    return _then(_PlaybackQueue(
      songs: null == songs
          ? _self._songs
          : songs // ignore: cast_nullable_to_non_nullable
              as List<Song>,
      currentIndex: null == currentIndex
          ? _self.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isSmartShuffleEnabled: null == isSmartShuffleEnabled
          ? _self.isSmartShuffleEnabled
          : isSmartShuffleEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
