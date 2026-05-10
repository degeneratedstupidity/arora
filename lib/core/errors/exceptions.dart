/// Custom typed exceptions for Arora.
///
/// Using typed exceptions instead of raw [Exception] or [String] errors allows
/// callers to handle specific failure modes with pattern matching.
///
/// ## Convention
/// - Throw these from data-layer code (repositories, data sources, providers).
/// - Catch and convert them to [Failure] types at the use-case boundary.
library;

// ---------------------------------------------------------------------------
// Base
// ---------------------------------------------------------------------------

/// Base class for all Arora-specific exceptions.
///
/// Carry a human-readable [message] for debugging. Do not display raw
/// exception messages to end users — map to [Failure] types instead.
sealed class AroraException implements Exception {
  const AroraException(this.message);

  /// Developer-facing description of what went wrong.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

// ---------------------------------------------------------------------------
// Provider / Network exceptions
// ---------------------------------------------------------------------------

/// Thrown when a stream URL cannot be resolved for a song.
///
/// This can happen when YouTube throttles requests, the video is geo-blocked,
/// or the internal API format has changed.
final class StreamUnavailableException extends AroraException {
  const StreamUnavailableException(super.message);
}

/// Thrown when a music video stream cannot be resolved.
final class VideoUnavailableException extends AroraException {
  const VideoUnavailableException(super.message);
}

/// Thrown when a network request fails (no connectivity, timeout, etc.).
final class NetworkException extends AroraException {
  const NetworkException(super.message, {this.statusCode});

  /// HTTP status code if available.
  final int? statusCode;
}

/// Thrown when the remote API returns unexpected / unparseable data.
final class ParseException extends AroraException {
  const ParseException(super.message);
}

// ---------------------------------------------------------------------------
// Local storage exceptions
// ---------------------------------------------------------------------------

/// Thrown when a local database operation fails.
final class DatabaseException extends AroraException {
  const DatabaseException(super.message);
}

/// Thrown when a requested item does not exist in the local database.
final class NotFoundException extends AroraException {
  const NotFoundException(super.message);
}

// ---------------------------------------------------------------------------
// Download exceptions
// ---------------------------------------------------------------------------

/// Thrown when a file download fails (disk full, permission denied, etc.).
final class DownloadException extends AroraException {
  const DownloadException(super.message);
}
