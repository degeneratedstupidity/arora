// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_shuffle_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SmartShuffleService)
final smartShuffleServiceProvider = SmartShuffleServiceProvider._();

final class SmartShuffleServiceProvider
    extends $NotifierProvider<SmartShuffleService, void> {
  SmartShuffleServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'smartShuffleServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$smartShuffleServiceHash();

  @$internal
  @override
  SmartShuffleService create() => SmartShuffleService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$smartShuffleServiceHash() =>
    r'08de7bc1498be4ff597582bfe3d013f0f225d1d3';

abstract class _$SmartShuffleService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
