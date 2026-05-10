import 'package:freezed_annotation/freezed_annotation.dart';

part 'lyrics.freezed.dart';

/// A single line of timed lyrics.
///
/// [startMs] is the millisecond offset from the start of the track
/// at which this line should be highlighted in the lyrics view.
@freezed
abstract class LyricLine with _$LyricLine {
  const factory LyricLine({
    /// Offset in milliseconds from track start for this line.
    required int startMs,

    /// The text content of this line.
    required String text,
  }) = _LyricLine;
}

/// Lyrics for a track — either timed (LRC-style) or plain text.
///
/// ## Synchronized vs plain lyrics
/// - When [timedLines] is non-empty, the Now Playing screen scrolls to the
///   active line in real time, synchronised with [AudioPlayerService].
/// - When [timedLines] is empty but [plainText] is set, lyrics are shown
///   as a static scrollable block.
///
/// Providers should always prefer returning timed lyrics when available.
@freezed
abstract class Lyrics with _$Lyrics {
  const factory Lyrics({
    /// Ordered list of timed lyric lines (LRC format).
    /// Empty when only plain text is available.
    @Default([]) List<LyricLine> timedLines,

    /// Full lyrics as a plain text string.
    /// Used when timed lines are unavailable.
    String? plainText,

    /// The language of the lyrics (ISO 639-1 code, e.g., `'en'`, `'hi'`).
    String? language,
  }) = _Lyrics;

  const Lyrics._();

  /// Returns `true` if timed synchronization data is available.
  bool get isSynced => timedLines.isNotEmpty;

  /// Returns `true` if any lyrics content is available.
  bool get hasContent => timedLines.isNotEmpty || (plainText?.isNotEmpty ?? false);
}
