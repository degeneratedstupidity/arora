import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arora/services/audio/playback_queue_notifier.dart';
import 'package:arora/domain/entities/playback_queue.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/services/liked_songs_service.dart';

part 'smart_shuffle_service.g.dart';

// Matches DJ sets, megamixes, and compilation titles — not individual tracks.
final _compilationPattern = RegExp(
  r'\bparty mix\b|\bbest of\b|\bcompilation\b|\bnon.?stop\b|\bmegamix\b',
  caseSensitive: false,
);

// Standard YouTube widescreen thumbnail resolutions indicate a video upload
// (live stream, let's play, compilation) rather than a music track.
// Music uploads typically use hqdefault or lh3.googleusercontent.com thumbnails.
final _videoThumbnailPattern = RegExp(
  r'hq720|maxresdefault|sddefault',
  caseSensitive: false,
);

@Riverpod(keepAlive: true)
class SmartShuffleService extends _$SmartShuffleService {
  bool _isFetching = false;
  final _random = math.Random();

  // Refill when 1 song remains ahead (i.e., 4 of 5 consumed).
  static const _threshold = 1;

  // Songs added per refill.
  static const _batchSize = 5;

  // Candidates fetched per API call (extra headroom for quality filtering).
  static const _fetchLimit = 12;

  // Reject anything longer than 10 minutes — catches compilations and DJ mixes.
  static const _maxDurationMs = 600000;

  static const _maxHeardHistory = 100;

  // Recent songs used as alternate Radio Mix seeds when the primary seed's
  // mix skews toward a single artist. Capped at 5 entries.
  static const _maxRecentSeeds = 5;
  final List<Song> _recentSeeds = [];

  // Artist search is only used as a last resort (both Radio Mix seeds empty).
  // Rate-limited to prevent search API pressure on rapid skips.
  static const _searchCooldown = Duration(seconds: 45);
  DateTime? _lastSearchAt;

  final Set<String> _heardSongIds = {};
  final List<String> _heardQueue = [];

  @override
  void build() {
    ref.listen(playbackQueueProvider, (previous, next) {
      if (previous != null && previous.currentIndex != next.currentIndex) {
        final justPlayed = previous.currentSong;
        if (justPlayed != null) {
          _addHeard(justPlayed.id);
          _updateRecentSeeds(justPlayed);
        }
        _checkQueueAndRefill(next);
      } else if (previous?.isSmartShuffleEnabled == false &&
          next.isSmartShuffleEnabled) {
        _checkQueueAndRefill(next, forceRefresh: true);
      }
    });
  }

  void _addHeard(String songId) {
    if (_heardSongIds.contains(songId)) return;
    _heardSongIds.add(songId);
    _heardQueue.add(songId);
    if (_heardQueue.length > _maxHeardHistory) {
      _heardSongIds.remove(_heardQueue.removeAt(0));
    }
  }

  void _updateRecentSeeds(Song song) {
    _recentSeeds.removeWhere((s) => s.id == song.id);
    _recentSeeds.add(song);
    if (_recentSeeds.length > _maxRecentSeeds) _recentSeeds.removeAt(0);
  }

  bool _isGoodSong(Song s) {
    if (s.durationMs != null &&
        (s.durationMs! > _maxDurationMs || s.durationMs! < 30000)) {
      return false;
    }
    if (_compilationPattern.hasMatch(s.title)) return false;
    if (s.thumbnailUrl != null &&
        _videoThumbnailPattern.hasMatch(s.thumbnailUrl!)) {
      return false;
    }
    return true;
  }

  bool _searchCooledDown() {
    if (_lastSearchAt == null) return true;
    return DateTime.now().difference(_lastSearchAt!) >= _searchCooldown;
  }

  // Interleave so no two consecutive songs share the same artist.
  List<Song> _diversifyArtists(List<Song> songs) {
    final byArtist = <String, List<Song>>{};
    for (final s in songs) {
      (byArtist[s.artistName] ??= []).add(s);
    }
    final result = <Song>[];
    String? lastArtist;
    while (byArtist.isNotEmpty) {
      final artists = byArtist.keys.toList();
      String? chosen;
      for (final a in artists) {
        if (a != lastArtist) {
          chosen = a;
          break;
        }
      }
      chosen ??= artists.first;
      final song = byArtist[chosen]!.removeAt(0);
      if (byArtist[chosen]!.isEmpty) byArtist.remove(chosen);
      result.add(song);
      lastArtist = song.artistName;
    }
    return result;
  }

  // Cap at 2 songs per artist, then interleave to prevent consecutive same-artist runs.
  List<Song> _selectBatch(List<Song> candidates, int batchSize) {
    final artistCount = <String, int>{};
    final capped = <Song>[];
    for (final s in candidates) {
      final c = artistCount[s.artistName] ?? 0;
      if (c < 2) {
        capped.add(s);
        artistCount[s.artistName] = c + 1;
      }
    }
    return _diversifyArtists(capped).take(batchSize).toList();
  }

  Future<void> _checkQueueAndRefill(
    PlaybackQueue queue, {
    bool forceRefresh = false,
  }) async {
    if (!queue.isSmartShuffleEnabled) return;
    if (queue.songs.isEmpty || queue.currentSong == null) return;
    if (_isFetching) return;

    final remaining = queue.songs.length - 1 - queue.currentIndex;
    if (!forceRefresh && remaining > _threshold) return;

    _isFetching = true;
    try {
      final musicProvider = ref.read(musicProviderProvider);
      final existingIds = queue.songs.map((s) => s.id).toSet();
      final seen = <String>{...existingIds, ..._heardSongIds};
      final candidates = <Song>[];

      void addIfFresh(Song s) {
        if (seen.contains(s.id) || !_isGoodSong(s)) return;
        seen.add(s.id);
        candidates.add(s);
      }

      if (!musicProvider.supportsRecommendations) return;

      // ── Primary seed: random liked song, or current song as fallback ─────
      // Seeding from liked songs reflects the user's taste without keyword
      // searches — YouTube's Radio Mix handles genre awareness internally.
      Song? primarySeed;
      try {
        final liked = ref.read(likedSongsProvider);
        // Prefer liked songs that pass the quality filter — avoids seeding
        // Radio Mix from compilations the user may have liked accidentally.
        final validLiked = liked.where(_isGoodSong).toList();
        if (validLiked.isNotEmpty) {
          primarySeed = validLiked[_random.nextInt(validLiked.length)];
        }
      } catch (_) {}
      primarySeed ??= queue.currentSong;

      if (primarySeed != null) {
        try {
          final recs = await musicProvider.getRecommendations(
            primarySeed.id,
            limit: _fetchLimit,
            artistHint: primarySeed.artistName,
            useSearchFallback: false,
          );
          recs.forEach(addIfFresh);
        } catch (_) {}
      }

      // ── Alternate seed: only when primary mix skews toward one artist ────
      // A Radio Mix seeded from the same scene often returns the same artist
      // multiple times. When fewer than 3 unique artists came back, we pick
      // the most recently played song from a different artist and run a second
      // Radio Mix. Both fetches use the playlist API — no search API involved.
      final primaryArtistCount =
          candidates.map((s) => s.artistName).toSet().length;
      if (primaryArtistCount < 3) {
        final primaryArtist = primarySeed?.artistName;
        Song? alternateSeed;
        for (var i = _recentSeeds.length - 1; i >= 0; i--) {
          if (_recentSeeds[i].artistName != primaryArtist) {
            alternateSeed = _recentSeeds[i];
            break;
          }
        }
        if (alternateSeed != null) {
          try {
            final altRecs = await musicProvider.getRecommendations(
              alternateSeed.id,
              limit: _fetchLimit,
              artistHint: alternateSeed.artistName,
              useSearchFallback: false,
            );
            altRecs.forEach(addIfFresh);
          } catch (_) {}
        }
      }

      // ── Last resort: artist search when Radio Mix has no results ─────────
      // Radio Mix is empty for songs not in YouTube Music's catalog (indie
      // artists, YouTube-only uploads). Artist search fills the gap, but uses
      // a rate-limited search API — capped to one call per 45 seconds so
      // rapid skips don't stack requests.
      if (candidates.isEmpty && _searchCooledDown()) {
        final artist = queue.currentSong?.artistName;
        if (artist != null && artist.isNotEmpty) {
          _lastSearchAt = DateTime.now();
          try {
            final songs = await musicProvider.searchSongs(
              '$artist music',
              limit: _fetchLimit,
            );
            songs.forEach(addIfFresh);
          } catch (_) {}
        }
      }

      if (candidates.isEmpty) return;

      final toAdd = _selectBatch(candidates, _batchSize);
      if (toAdd.isEmpty) return;

      final queueNotifier = ref.read(playbackQueueProvider.notifier);
      if (forceRefresh) {
        // Shuffle button clicked — discard stale upcoming and start fresh.
        queueNotifier.replaceUpcoming(toAdd);
      } else {
        // Threshold reached — append 5 more songs ahead.
        queueNotifier.addAllLast(toAdd);
      }
    } catch (_) {
      // Silently fail when offline or API unavailable.
    } finally {
      _isFetching = false;
    }
  }
}
