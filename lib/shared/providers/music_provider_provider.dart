import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/domain/providers/music_provider.dart';

/// The active [MusicProvider] — exposed as a standalone provider so that
/// feature providers and use-case providers can import it without circular
/// dependencies on `lib/app.dart`.
///
/// The actual implementation is overridden by `ProviderScope` via
/// `app.dart`'s `musicProviderProvider` registration.
///
/// This file acts as the canonical import point for all feature-level code.
final musicProviderProvider = Provider<MusicProvider>((ref) {
  throw UnimplementedError(
    'musicProviderProvider must be overridden in the root ProviderScope. '
    'Make sure app.dart registers the provider correctly.',
  );
});
