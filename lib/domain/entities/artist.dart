import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist.freezed.dart';

/// Represents a music artist or band.
@freezed
abstract class Artist with _$Artist {
  const factory Artist({
    /// Provider-specific artist identifier.
    required String id,

    /// Artist display name.
    required String name,

    /// URL to artist portrait / avatar image.
    String? imageUrl,

    /// Short biography text, if available.
    String? bio,
  }) = _Artist;
}
