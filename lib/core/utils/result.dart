/// A minimal Result<S, F> monad for explicit error handling.
///
/// Instead of throwing exceptions across layer boundaries, Arora's use-cases
/// return `Result<S, F>` so that callers must explicitly handle both the
/// success and failure paths at compile time.
///
/// ## Usage
/// ```dart
/// // Returning a result
/// Future<Result<String, Failure>> getUrl() async {
///   try {
///     final url = await provider.getStreamUrl(id);
///     return Success(url);
///   } on StreamUnavailableException {
///     return Failure(StreamFailure());
///   }
/// }
///
/// // Consuming a result
/// final result = await getUrlUseCase(songId);
/// switch (result) {
///   case Success(:final value) => playUrl(value);
///   case Err(:final failure)   => showError(failure.userMessage);
/// }
/// ```
library;

/// The base Result type. Either a [Success] or an [Err].
sealed class Result<S, F> {
  const Result();

  /// True if this is a [Success].
  bool get isSuccess => this is Success<S, F>;

  /// True if this is an [Err].
  bool get isError => this is Err<S, F>;

  /// Returns the success value, or null if this is an [Err].
  S? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Err() => null,
      };

  /// Returns the failure, or null if this is a [Success].
  F? get failureOrNull => switch (this) {
        Err(:final failure) => failure,
        Success() => null,
      };

  /// Maps the success value with [transform], leaving errors unchanged.
  Result<T, F> map<T>(T Function(S value) transform) => switch (this) {
        Success(:final value) => Success(transform(value)),
        Err(:final failure) => Err(failure),
      };
}

/// A successful result carrying a [value] of type [S].
final class Success<S, F> extends Result<S, F> {
  const Success(this.value);

  /// The successful return value.
  final S value;
}

/// A failed result carrying a [failure] of type [F].
final class Err<S, F> extends Result<S, F> {
  const Err(this.failure);

  /// The failure describing what went wrong.
  final F failure;
}
