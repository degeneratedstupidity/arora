// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liked_songs_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LikedSongsNotifier)
final likedSongsProvider = LikedSongsNotifierProvider._();

final class LikedSongsNotifierProvider
    extends $NotifierProvider<LikedSongsNotifier, List<Song>> {
  LikedSongsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'likedSongsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$likedSongsNotifierHash();

  @$internal
  @override
  LikedSongsNotifier create() => LikedSongsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Song> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Song>>(value),
    );
  }
}

String _$likedSongsNotifierHash() =>
    r'f0853efaec4ef13f025ca19fa639255adf450119';

abstract class _$LikedSongsNotifier extends $Notifier<List<Song>> {
  List<Song> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Song>, List<Song>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<Song>, List<Song>>, List<Song>, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
