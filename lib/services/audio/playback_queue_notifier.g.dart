// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_queue_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlaybackQueueNotifier)
final playbackQueueProvider = PlaybackQueueNotifierProvider._();

final class PlaybackQueueNotifierProvider
    extends $NotifierProvider<PlaybackQueueNotifier, PlaybackQueue> {
  PlaybackQueueNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'playbackQueueProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$playbackQueueNotifierHash();

  @$internal
  @override
  PlaybackQueueNotifier create() => PlaybackQueueNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackQueue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackQueue>(value),
    );
  }
}

String _$playbackQueueNotifierHash() =>
    r'ce019cc771563f19e4783a0802939889e85a6149';

abstract class _$PlaybackQueueNotifier extends $Notifier<PlaybackQueue> {
  PlaybackQueue build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlaybackQueue, PlaybackQueue>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PlaybackQueue, PlaybackQueue>,
        PlaybackQueue,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
