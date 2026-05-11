# Arora Music Player — Project Overview

This document is the canonical context reference for developers and AI agents working on this codebase. It describes the current architecture, key design decisions, known constraints, and contributor guidelines.

---

## What Is Arora?

Arora is a free, open-source, cross-platform music player built with Flutter. It streams audio and HD video directly from YouTube using `youtube_explode_dart` — no API key, no subscription. The app targets Android, iOS, Linux, macOS, and Windows from a single Dart codebase.

**Project path:** `lib/` (all application code)
**Entry point:** `lib/main.dart`
**App widget:** `lib/app.dart`

---

## Technology Stack

| Concern | Package | Version |
|---|---|---|
| UI framework | Flutter | 3.x |
| State management | flutter_riverpod + riverpod_annotation | 3.x / 4.x |
| Navigation | go_router | 14.x |
| Audio (all platforms) | just_audio | 0.9.x |
| Audio (Linux backend) | just_audio_media_kit + media_kit_libs_audio | 2.x / 1.x |
| Background audio | audio_service | 0.18.x |
| Video | video_player + chewie | 2.x / 1.x |
| YouTube data | youtube_explode_dart | 3.x |
| Authentication | google_sign_in + extension_google_sign_in_as_googleapis_auth | 6.x / 2.x |
| HTTP client | http | 1.x |
| Local storage | hive_ce | 2.x |
| HTTP downloads | dio | 5.x |
| Immutable entities | freezed + freezed_annotation | 3.x |
| Code generation | build_runner, riverpod_generator, hive_ce_generator | — |
| Desktop window | window_manager | 0.4.x |
| Image caching | cached_network_image | 3.x |
| Fonts | google_fonts | 6.x |

**Removed:** Isar database (was replaced by Hive CE in all data layer code).

---

## Architecture

Arora follows Clean Architecture with a feature-first directory layout inside `lib/features/`.

```
lib/
├── core/
│   ├── constants/        # AppConstants, env keys
│   ├── errors/           # Typed exception hierarchy (AroraException subclasses)
│   ├── extensions/       # Dart extensions (Duration.toMMSS, etc.)
│   ├── theme/            # AppColors, AppTheme, ThemeProvider, SettingsScreen
│   └── utils/            # AroraLogger
├── domain/
│   ├── entities/         # Freezed value objects: Song, Playlist, Album, Lyrics, PlaybackQueue
│   ├── enums/            # AudioQuality, VideoQuality
│   ├── providers/        # MusicProvider abstract contract
│   └── usecases/         # GetStreamUrlUseCase, GetVideoUrlUseCase
├── data/
│   ├── datasources/local/  # HiveDatabase — opens and registers all Hive boxes
│   └── repositories/       # PlaylistRepositoryImpl (Box<Playlist>)
├── infrastructure/
│   ├── auth/             # YoutubeAuthService, auth_providers.dart (Google OAuth)
│   ├── youtube/          # YoutubeExplodeMusicProvider (constructor accepts http.Client? but ignores it — see Stream type note)
│   └── mock/             # MockMusicProvider (for testing)
├── services/
│   ├── audio/            # AudioPlayerService, PlaybackQueueNotifier, SmartShuffleService,
│   │                     # AudioServiceHandler
│   ├── download/         # DownloadManager (Dio + Hive Box<Song>)
│   └── cache_service.dart # In-memory URL cache with TTL
├── features/
│   ├── home/             # HomeScreen, TrendingRail, home_providers
│   ├── search/           # SearchScreen, search_providers
│   ├── player/           # NowPlayingScreen, PlayerControls, MiniPlayerBar,
│   │                     # BlurredBackground, LyricsScreen, player_providers
│   ├── library/          # LibraryScreen, ImportPlaylistScreen, library_providers
│   ├── downloads/        # DownloadsScreen, download_providers
│   ├── queue/            # QueueScreen
│   └── settings/         # EqualizerScreen
├── shared/
│   ├── providers/        # musicProviderProvider (the DI injection point)
│   └── widgets/          # AroraImage, AroraLoadingIndicator, ErrorView,
│                         # WindowTitleBar, LoadingIndicator
└── services/
    └── playlist_import_service.dart
```

---

## The MusicProvider Pattern

**The single most important design decision in this codebase.**

All UI and business logic depends exclusively on the abstract `MusicProvider` interface in `lib/domain/providers/music_provider.dart`. The concrete implementation (`YoutubeExplodeMusicProvider`) is injected once in `lib/app.dart` via the `musicProviderProvider` Riverpod override.

**Consequence:** swapping the entire music backend (e.g. YouTube → Spotify → Deezer) requires:
1. A new class in `lib/infrastructure/<name>/`
2. One line changed in `lib/app.dart`
3. Zero UI or business logic changes

**`getRecommendations` signature:**
```dart
Future<List<Song>> getRecommendations(
  String songId, {
  int limit = 20,
  String? artistHint,  // pass Song.artistName to skip extra network lookup in fallback
});
```
Always pass `artistHint` when you have a `Song` object — it prevents an extra `_yt.videos.get()` call in the Radio Mix fallback path.

---

## Key Files Quick-Reference

| File | What it does |
|---|---|
| `lib/main.dart` | Hive init, media_kit init, **auth silent sign-in**, window_manager init, ProviderScope |
| `lib/app.dart` | GoRouter, adaptive shell, keyboard shortcuts, recently-played listener, `buildProviderOverrides()` |
| `lib/infrastructure/auth/youtube_auth_service.dart` | Google OAuth: `signIn()`, `signOut()`, `signInSilently()`, `getAuthenticatedClient()` |
| `lib/infrastructure/auth/auth_providers.dart` | `youtubeAuthServiceProvider` — singleton auth service for the widget tree |
| `lib/data/datasources/local/hive_database.dart` | Opens `Box<Playlist>`, `Box<Song>`, `Box<Settings>`; registers TypeAdapters; self-heals stale lock files |
| `lib/infrastructure/youtube/youtube_explode_music_provider.dart` | Full YouTube implementation: search, stream URLs, metadata, lyrics, trending, Radio Mix recommendations |
| `lib/services/audio/audio_player_service.dart` | Core engine: wraps `AudioPlayer`, manages queue listener, pre-fetches URLs, exposes reactive streams |
| `lib/services/audio/playback_queue_notifier.dart` | `@Riverpod(keepAlive: true)` queue state — `playSong`, `playPlaylist`, `next` (wraps), `previous` |
| `lib/services/audio/audio_service_handler.dart` | Global singleton `aroraAudioHandler` — bridges `AudioPlayerService` to `audio_service` via lazy `connect()` callbacks; `onSongChanged()` updates lock screen + notification |
| `lib/services/audio/smart_shuffle_service.dart` | Watches queue; when ≤ 3 songs remain and shuffle is on, fetches Radio Mix (`RD{id}`); tracks `_recentSeeds` for variety; falls back to different-artist seed when primary mix is exhausted |
| `lib/services/download/download_manager.dart` | Dio download with YouTube CDN headers; stores `Song(isDownloaded: true)` in `Box<Song>` |
| `lib/features/home/providers/home_providers.dart` | `trendingProvider`, `genreSongsProvider`, `recommendedForYouProvider`, `recentlyPlayedProvider` |
| `lib/features/player/providers/player_providers.dart` | `audioPlayerServiceProvider`, `currentSongProvider`, `isPlayingProvider`, `volumeProvider`, etc. |
| `lib/features/player/widgets/player_controls.dart` | `ProgressBarWidget` (200ms polling timer), `PlayerControls`, `_VolumeBar` |
| `lib/core/theme/theme_provider.dart` | `@riverpod AppTheme theme(Ref)` — reads SettingsService, generates Material 3 ThemeData |

---

## Hive Storage

**No Isar.** All local storage uses Hive CE only.

| Box name | Key | Dart type | TypeAdapter typeId |
|---|---|---|---|
| `playlistsBox` | playlist.id | `Playlist` | 1 |
| `downloadsBox` | song.id | `Song` | 0 |
| `settingsBox` | `'settings'` | `Settings` | 3 |
| `searchHistoryBox` | auto-int | `String` | n/a (primitive) |

Box names are constants on `HiveDatabase`:
- `HiveDatabase.playlistsBoxName`
- `HiveDatabase.downloadsBoxName`
- `HiveDatabase.settingsBoxName`
- `HiveDatabase.searchHistoryBoxName`

`_openBoxSafe<T>()` in `HiveDatabase` handles stale `.lock` files automatically by deleting and retrying.

---

## Audio Engine Details

### Linux backend
`just_audio` has no built-in Linux implementation. `just_audio_media_kit` bridges to `media_kit`, which uses the system `libmpv`.  
**Requirement:** `sudo pacman -S mpv` (Arch) or `sudo apt install libmpv-dev` (Debian/Ubuntu).  
`JustAudioMediaKit.ensureInitialized(linux: true)` is called at the top of `main()`.

### Android-only audio pipeline
`AndroidEqualizer` and `AndroidLoudnessEnhancer` are guarded by `defaultTargetPlatform == TargetPlatform.android` in `AudioPlayerService`. On Linux/macOS/Windows both fields are `null`. All callers use `?.` null-safe access. `EqualizerScreen` shows a graceful "Android only" message when the equalizer is null.

### Position stream
`positionStream` from `just_audio_media_kit` (Linux) updates only ~once per second. `_ProgressBarWidgetState` in `player_controls.dart` compensates with a `Timer.periodic(200ms)` that polls `audioPlayerServiceProvider.position` directly.

### Queue lifecycle
1. User taps a song → `AudioPlayerService.playQueue()` → `PlaybackQueueNotifier.playPlaylist()`
2. Queue state change → `_ref.listen(playbackQueueProvider, ...)` in `AudioPlayerService` detects `songChanged || indexChanged` → `_loadAndPlaySong(song)`
3. Song emitted to `_currentSongController` immediately (before URL resolution) so NowPlayingScreen renders at once
4. `_player.stop()` and `_resolveUrl(song)` run **in parallel** — old audio silenced while new URL is fetched. `_resolveUrl` returns a muxed mp4 URL (itag=18); just_audio/mpv extract the audio track.
5. `AudioSource` set, playback begins
6. `ProcessingState.completed` → `skipNext()` → `next()` (wraps around), or fetches recommendations if queue has only 1 song

### Skip on single-song queue
When `skipNext()` is called with only 1 song queued, `PlaybackQueueNotifier.next()` would produce `(0+1) % 1 = 0` — identical Riverpod state — so the queue listener never fires. Instead, `skipNext()` detects this case, calls `musicProviderProvider.getRecommendations()` directly, appends results with `addAllLast()`, then advances. A race-condition guard (`latestQueue.currentSong?.id != currentSong.id`) aborts if the user started a different song during the async fetch.

### Media session / lock screen (Android)
`aroraAudioHandler` (global singleton in `audio_service_handler.dart`) is registered with `AudioService.init` at startup. After Riverpod creates `AudioPlayerService`, `player_providers.dart` calls `aroraAudioHandler.connect(...)` with plain closures — no direct import of `AudioPlayerService` in the handler (avoids circular imports). `AudioPlayerService` fires its `onMediaChanged` callback:
- Immediately after emitting the new song to `_currentSongController` → lock screen artwork + title appear before URL resolves
- From `playingStream` listener → notification play/pause button stays in sync
`broadcastState()` emits `AudioProcessingState.loading` while the URL is being fetched so the notification shows a loading state rather than staying idle.

### Smart Shuffle
- Enabled via `PlaybackQueueNotifier.toggleSmartShuffle()`
- `SmartShuffleService` watches the queue; when `remaining ≤ 3` and shuffle is on, calls `getRecommendations(currentSong.id)` (threshold was 2)
- Fetches 15 songs per batch (was 10)
- Tracks `_recentSeeds` (last 5 played songs, newest-first). When the primary Radio Mix returns < 3 new songs (exhausted), fetches from the most recent different-artist seed for variety — avoids doubling API calls on normal playback
- New songs appended via `addAllLast()`, which deduplicates against the existing queue

---

## Download Flow

1. `DownloadManager.download(song)` called
2. `GetStreamUrlUseCase` resolves stream URL (high quality)
3. Dio downloads to `{documentsDir}/arora_downloads/{id}.audio` with YouTube CDN headers (`User-Agent`, `Origin`, `Referer`)
4. `onReceiveProgress` emits `DownloadProgress` events; handles `Content-Length: -1` gracefully
5. `Song.copyWith(isDownloaded: true, localFilePath: ...)` persisted to `Box<Song>`
6. On playback, `AudioPlayerService._loadAndPlaySong` checks `song.isDownloaded` and uses `AudioSource.file` instead of a network URL

---

## Navigation (Routes)

| Path | Screen | Shell? |
|---|---|---|
| `/` | HomeScreen | Yes (adaptive nav + MiniPlayer) |
| `/search` | SearchScreen | Yes |
| `/library` | LibraryScreen | Yes |
| `/downloads` | DownloadsScreen | Yes |
| `/player` | NowPlayingScreen | No (full-screen) |
| `/settings` | SettingsScreen | No |
| `/queue` | QueueScreen | No |
| `/equalizer` | EqualizerScreen | No |
| `/import_playlist` | ImportPlaylistScreen | No |

The shell (`_AdaptiveShell` in `app.dart`) switches between `_MobileLayout` (BottomNavigationBar) and `_DesktopLayout` (NavigationRail) at 800 px. Above 1200 px the rail extends with text labels.

---

## Home Screen Discovery

The Home screen loads three types of content:

1. **Trending Now** — `trendingProvider` fetches YouTube playlist `PLFgquLnL59alCl_2TQvOiD5Vgm1hCaGSI`. Loads immediately; marked `keepAlive` so it never re-fetches on navigation.
2. **Because you listened to X** — `recommendedForYouProvider` reads `recentlyPlayedProvider` (via `ref.read`, not `ref.watch`) and calls `getRecommendations(seed.id, artistHint: seed.artistName)`. Appears only after the first song is played. Re-runs once each time the user navigates to the Home screen, not on every song change. `AroraApp.build()` populates `recentlyPlayedProvider` by listening to `currentSongProvider`.
3. **Genre rails** — `genreSongsProvider(query)` (FutureProvider.family) for each entry in `homeGenres`: Pop Hits, Hip-Hop, Electronic. Each genre waits for `trendingProvider` to complete, then staggers 1.5 s apart to avoid concurrent YouTube requests. Results cached with `keepAlive`.

All three sections reuse `TrendingRail` for display.

---

## Provider Name Reference

A common source of confusion: Riverpod's generator strips `Notifier` from the class name.

| Class | Provider name | Location |
|---|---|---|
| `PlaybackQueueNotifier` | `playbackQueueProvider` | `playback_queue_notifier.g.dart` |
| `SmartShuffleService` | `smartShuffleServiceProvider` | `smart_shuffle_service.g.dart` |
| `PlaylistImportNotifier` | `playlistImportNotifierProvider` | `playlist_import_service.g.dart` |
| `AudioPlayerService` | `audioPlayerServiceProvider` | `player_providers.dart` (manual) |
| `RecentlyPlayedNotifier` | `recentlyPlayedProvider` | `home_providers.dart` (manual) |

---

## Build & Code Generation

```bash
# Full code generation (run after any entity/provider change)
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs

# Static analysis
flutter analyze

# Tests
flutter test
```

Generated files (do not edit manually): `*.freezed.dart`, `*.g.dart`

---

## Current Build Status

- `flutter build linux --debug` → **✓ Built** — 0 errors, 0 warnings
- `JAVA_HOME=/opt/android-studio/jbr flutter build apk --debug` → **✓ Built** `app-debug.apk`
- `flutter analyze` → 0 errors, 0 warnings (pre-existing style infos only)
- All features confirmed working on **Linux and Android** (vivo 1920) as of May 2026, including lock screen controls and notification player
- **Stream type:** `manifest.muxed` (itag=18, video/mp4 96 kbps AAC). YouTube's CDN blocks audio-only opus/webm streams (itag=251) for external players (mpv, ExoPlayer) that lack YouTube session cookies. Muxed mp4 streams are freely accessible; just_audio/mpv/ExoPlayer extract the audio track automatically.
- **Phase 1 OAuth implementation complete** — `YoutubeAuthService` / `_GoogleAccountTile` in Settings. The authenticated http.Client is **not** passed into `YoutubeExplode` (doing so caused 403s — the library's own cookie-based session is the correct credential mechanism). OAuth is useful for personal library access on Android; playback, search, and recommendations work without it.
- Android Cloud Console: Firebase project `arora-495906`, SHA-1 fingerprint registered, `google-services.json` in `android/app/`. Test user `celeticcharger@gmail.com` whitelisted.

### Rate limiting mitigation
`youtube_explode_dart` uses YouTube's internal API without authentication; YouTube enforces per-IP rate limits. The following design decisions keep request volume within safe bounds:

| Mitigation | Where |
|---|---|
| Genre searches staggered — load after trending, 1.5 s apart | `genreSongsProvider` |
| `trendingProvider` + `genreSongsProvider` marked `keepAlive` | `home_providers.dart` |
| `recommendedForYouProvider` uses `ref.read` (runs once per home mount) | `home_providers.dart` |
| Next-song URL pre-fetch removed from queue listener | `AudioPlayerService` constructor |
| `artistHint` param on `getRecommendations` skips extra `_yt.videos.get()` | `MusicProvider` interface |
| URL deduplication via `_pendingUrlFetches` — concurrent callers share one request | `AudioPlayerService._resolveUrl` |

---

## Known Limitations

- **Equalizer** is Android-only. Route `/equalizer` exists but no button links to it from `SettingsScreen` yet.
- **YouTube stream URLs expire after ~6 hours.** `CacheService` stores URLs with `AppConstants.streamUrlTtl`. Long sessions may need a fresh URL.
- **Playback start latency (~2-4 s)** — `youtube_explode_dart`'s `getManifest` makes several internal HTTP round-trips to YouTube per call. This is inherent to the unofficial API; no workaround without YouTube authentication.
- **Skip latency on single-song queue (~4-8 s)** — `skipNext()` must first fetch recommendations (3-4 s) then resolve the new song's URL (3-4 s) sequentially. Proactive pre-fetching was removed to prevent rate limiting. Once the queue has multiple songs (after first skip), subsequent skips are fast.
- **Audio quality capped at 96 kbps AAC** — YouTube's CDN restricts audio-only streams (opus/webm, itag=251) to requests carrying YouTube session cookies (managed by Dart's `dart:io` HttpClient inside `youtube_explode_dart`). External players (mpv, ExoPlayer) have no such cookies and receive HTTP 403. We use muxed streams (video+audio mp4, itag=18), which are freely served. Bandwidth is ~5× higher per song than pure audio. Quality difference is audible only on audiophile equipment.
- **Offline shuffle** — SmartShuffleService requires network. Queue stops auto-refilling when offline.
- **YouTube rate limiting** — Without authenticated cookies, YouTube enforces per-IP limits. Staggered loading and reduced concurrent requests mitigate this but cannot eliminate it entirely under heavy use.

---

## AI Agent Guidelines

Follow these rules when modifying this codebase:

**State management**
- Always use modern Riverpod annotations: `@riverpod`, `Notifier`, `AsyncNotifier`.
- Never use `StateProvider`, `StateNotifierProvider`, or `ChangeNotifier`.
- The generated provider name is the class name with `Notifier` stripped — e.g. `PlaybackQueueNotifier` → `playbackQueueProvider`.

**Data models**
- Freezed 3.x requires `abstract class MyModel with _$MyModel` (not `class`).
- All entities live in `lib/domain/entities/`. Do not mix DTOs into domain.

**Local storage**
- Use only `hive_ce`. There is no Isar in this project.
- Never open a Hive box directly — use the pre-opened boxes via `Hive.box<T>(HiveDatabase.*BoxName)`.
- Store domain entities (`Song`, `Playlist`) directly. Do not introduce DTO models.

**Music provider**
- Never import a concrete provider (e.g. `YoutubeExplodeMusicProvider`) in feature or service code.
- Always depend on `musicProviderProvider` from `lib/shared/providers/music_provider_provider.dart`.

**Audio service**
- The singleton is `audioPlayerServiceProvider` in `lib/features/player/providers/player_providers.dart`.
- Playback is driven through `PlaybackQueueNotifier`, not by calling `AudioPlayer` directly.
- `aroraAudioHandler` (global in `audio_service_handler.dart`) is the `BaseAudioHandler` registered with `AudioService.init`. Wire it via `aroraAudioHandler.connect(...)` in the provider — never import `AudioPlayerService` directly into `audio_service_handler.dart` (circular import).
- `AudioPlayerService.onMediaChanged` is a `void Function()?` callback fired on song change and play/pause toggle. Always pass `aroraAudioHandler.onSongChanged` here.

**Imports**
- Do not import `player_providers.dart` in `home_providers.dart` — this creates a circular dependency through `currentSongProvider`. The `recentlyPlayedProvider` listener belongs in `app.dart`, not in home providers.
- Do not import `audio_player_service.dart` in `audio_service_handler.dart` — use the callback pattern via `connect()` instead.
