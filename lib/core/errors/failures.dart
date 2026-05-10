/// Failure types for the Result monad pattern used in Arora.
///
/// [Failure] types are what use-cases and the UI layer reason about.
/// They are created by converting raw [AroraException]s at repository
/// or use-case boundaries.
///
/// ## Why separate Exceptions from Failures?
/// - [AroraException]s carry raw technical detail (HTTP codes, stack traces).
/// - [Failure]s carry user-facing meaning ("No internet", "Song unavailable").
/// - The UI layer imports only [Failure] — it never sees raw exceptions.
library;

// ---------------------------------------------------------------------------
// Base
// ---------------------------------------------------------------------------

/// Base class for all user-facing failure types.
sealed class Failure {
  const Failure(this.userMessage);

  /// A short, user-facing description of what went wrong.
  /// Safe to display in a [SnackBar] or error card.
  final String userMessage;

  @override
  String toString() => '$runtimeType($userMessage)';
}

// ---------------------------------------------------------------------------
// Concrete failures
// ---------------------------------------------------------------------------

/// The device has no internet connectivity.
final class NoInternetFailure extends Failure {
  const NoInternetFailure()
      : super('No internet connection. Please check your network.');
}

/// The requested audio/video stream is not available.
final class StreamFailure extends Failure {
  const StreamFailure([super.userMessage = 'This song is currently unavailable.']);
}

/// The music video is not available for this track.
final class VideoFailure extends Failure {
  const VideoFailure([super.userMessage = 'Music video is unavailable for this track.']);
}

/// The remote API returned an unexpected or unparseable response.
final class ServerFailure extends Failure {
  const ServerFailure([super.userMessage = 'Something went wrong. Please try again.']);
}

/// A local database read or write failed.
final class StorageFailure extends Failure {
  const StorageFailure([super.userMessage = 'Could not access local storage.']);
}

/// The requested item was not found (locally or remotely).
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.userMessage = 'Item not found.']);
}

/// A file download operation failed.
final class DownloadFailure extends Failure {
  const DownloadFailure([super.userMessage = 'Download failed. Please try again.']);
}
