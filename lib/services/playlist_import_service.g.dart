// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_import_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlaylistImportNotifier)
final playlistImportProvider = PlaylistImportNotifierProvider._();

final class PlaylistImportNotifierProvider
    extends $NotifierProvider<PlaylistImportNotifier, AsyncValue<List<Song>>> {
  PlaylistImportNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'playlistImportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$playlistImportNotifierHash();

  @$internal
  @override
  PlaylistImportNotifier create() => PlaylistImportNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Song>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Song>>>(value),
    );
  }
}

String _$playlistImportNotifierHash() =>
    r'3055b5b3fccc43c28152e7747735153aaffdb9fb';

abstract class _$PlaylistImportNotifier
    extends $Notifier<AsyncValue<List<Song>>> {
  AsyncValue<List<Song>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Song>>, AsyncValue<List<Song>>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Song>>, AsyncValue<List<Song>>>,
        AsyncValue<List<Song>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
