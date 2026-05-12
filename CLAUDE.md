# Arora — CLAUDE.md

Single source of truth for AI agents. Read this file instead of PROJECT_OVERVIEW.md, IMPLEMENTATION_PLAN.md, README.md, or the memory files. Everything here is current as of Session 9 (May 2026).

---

## What Is Arora

Cross-platform Flutter music player that streams audio and video from YouTube with no API key and no subscription. Uses `youtube_explode_dart` to reverse-engineer YouTube's internal API (same technique as yt-dlp). Targets Android and Linux; iOS/macOS/Windows should work but are untested.

**Project root:** `/home/cb/AntiGravity/projekt_2/arora`
**Entry point:** `lib/main.dart` → `lib/app.dart`

---

## Build Commands

```bash
# Linux desktop
flutter run -d linux
flutter build linux --debug

# Android (must set JAVA_HOME — system Flutter uses Android Studio's bundled JDK)
JAVA_HOME=/opt/android-studio/jbr flutter run -d a536bde8   # vivo 1920 (device ID)
JAVA_HOME=/opt/android-studio/jbr flutter build apk --debug

# Code generation (run after any entity/provider/Hive model change)
dart run build_runner build --delete-conflicting-outputs

# Static analysis
flutter analyze    # must return 0 errors, 0 warnings
```

**Current build status:** Both Linux and Android build clean — 0 errors, 0 warnings. `flutter analyze` clean.

**Current version:** `1.1.0+2` (pubspec.yaml). Tagged `v1.1.0` on GitHub; CI builds release APK + AppImage automatically on tag push.

**UI redesign status:** All 4 steps complete (Session 8). Playlist fixes applied (Session 9). Zero runtime errors confirmed on Android (vivo 1920).

---

## Tech Stack

| Concern | Package | Version |
|---|---|---|
| UI | Flutter | 3.x |
| State | flutter_riverpod + riverpod_annotation | 3.x / 4.x |
| Navigation | go_router | 14.x |
| Audio (all) | just_audio | 0.9.x |
| Audio (Linux) | just_audio_media_kit + media_kit_libs_audio | 2.x / 1.x |
| Background audio / media session | audio_service | 0.18.x |
| Video | video_player + chewie | 2.x / 1.x |
| YouTube data | youtube_explode_dart | **3.1.0** |
| Auth | google_sign_in + extension_google_sign_in_as_googleapis_auth | 6.x / 2.x |
| HTTP | http | 1.x |
| Local storage | hive_ce | 2.x |
| Downloads | dio | 5.x |
| Immutable entities | freezed + freezed_annotation | 3.x |
| Code gen | build_runner, riverpod_generator, hive_ce_generator | — |
| Desktop window | window_manager | 0.4.x |
| Theme file import | file_picker | 8.x |

**Not in project:** Isar (removed), `StateProvider`/`StateNotifierProvider`/`ChangeNotifier` (never use).

---

## Directory Structure

```
lib/
├── core/
│   ├── constants/      AppConstants, env keys
│   ├── errors/         AroraException hierarchy
│   ├── extensions/     Duration.toMMSS, etc.
│   ├── theme/          AppColors, AppTheme, ThemeProvider, SettingsScreen
│   └── utils/          AroraLogger
├── domain/
│   ├── entities/       Song, Playlist, Album, Lyrics, PlaybackQueue  (Freezed)
│   ├── enums/          AudioQuality, VideoQuality
│   ├── providers/      MusicProvider  (abstract contract — DO NOT bypass)
│   └── usecases/       GetStreamUrlUseCase, GetVideoUrlUseCase
├── data/
│   ├── datasources/local/   HiveDatabase
│   └── repositories/        PlaylistRepositoryImpl
├── infrastructure/
│   ├── auth/           YoutubeAuthService, auth_providers.dart
│   ├── youtube/        YoutubeExplodeMusicProvider
│   └── mock/           MockMusicProvider
├── services/
│   ├── audio/          AudioPlayerService, PlaybackQueueNotifier,
│   │                   SmartShuffleService, AudioServiceHandler
│   ├── download/       DownloadManager
│   └── cache_service.dart
├── features/
│   ├── home/           HomeScreen, TrendingRail, home_providers
│   ├── search/         SearchScreen, search_providers, search_history_notifier
│   ├── player/         NowPlayingScreen, PlayerControls, MiniPlayerBar,
│   │                   LyricsScreen, player_providers
│   ├── library/        LibraryScreen, ImportPlaylistScreen
│   ├── downloads/      DownloadsScreen
│   ├── queue/          QueueScreen
│   └── settings/       EqualizerScreen
└── shared/
    ├── providers/      musicProviderProvider  (DI injection point)
    └── widgets/        AroraImage, ErrorView, WindowTitleBar, LoadingIndicator
```

---

## Critical Design Decisions

### 1. Stream type: always muxed mp4, never audio-only

YouTube's CDN serves two stream classes:
- **Audio-only (itag=251, opus/webm):** Requires YouTube session cookies. `youtube_explode_dart` has them internally; external players (mpv, ExoPlayer) do not → HTTP 403.
- **Muxed (itag=18, video+audio mp4, 96 kbps AAC):** No session required. Works everywhere.

`getStreamUrl` in `YoutubeExplodeMusicProvider` uses `manifest.muxed` sorted by bitrate. `just_audio`/mpv/ExoPlayer extract the audio track automatically. **Never change this to `manifest.audioOnly`.**

### 2. OAuth client must NOT go into YoutubeExplode

`YoutubeExplodeMusicProvider` constructor accepts `[http.Client? httpClient]` but ignores it:

```dart
YoutubeExplodeMusicProvider([http.Client? httpClient])
    : _yt = yt.YoutubeExplode(); // plain unauthenticated — correct
```

Passing an authenticated `googleapis` http.Client into `YoutubeExplode` caused HTTP 403 on **all** stream URLs. The library's cookie-based session is the correct credential; OAuth headers interfere. OAuth is only useful for accessing the user's personal YouTube playlists.

### 3. AudioServiceHandler uses callbacks, not a direct reference

`AudioServiceHandler` (`audio_service_handler.dart`) must not import `AudioPlayerService` — circular import. Instead a global singleton `aroraAudioHandler` exposes `connect(...)` which accepts plain closures. `player_providers.dart` calls it after Riverpod creates the service:

```dart
// player_providers.dart
aroraAudioHandler.connect(
  onPlay: service.resume,
  onPause: service.pause,
  onSkipNext: service.skipNext,
  ...
);
```

`AudioPlayerService` holds a `void Function()? onMediaChanged` callback. Pass `aroraAudioHandler.onSongChanged` here. It fires on song change and play/pause toggle to keep the notification/lock screen in sync.

### 4. MusicProvider is the only dependency allowed in features

All feature code and services must depend on `musicProviderProvider` from `lib/shared/providers/music_provider_provider.dart`. Never import `YoutubeExplodeMusicProvider` directly outside of `lib/app.dart`.

### 5. Riverpod provider naming

The generated provider name is the class name with `Notifier` stripped:

| Class | Provider |
|---|---|
| `PlaybackQueueNotifier` | `playbackQueueProvider` ← very commonly confused |
| `SmartShuffleService` | `smartShuffleServiceProvider` |
| `PlaylistImportNotifier` | `playlistImportNotifierProvider` |
| `AudioPlayerService` | `audioPlayerServiceProvider` (manual, in player_providers.dart) |
| `RecentlyPlayedNotifier` | `recentlyPlayedProvider` (manual, in home_providers.dart) |

---

## Key Files

| File | Role |
|---|---|
| `lib/main.dart` | Bootstrap: Hive, media_kit, auth silent sign-in, `AudioService.init(aroraAudioHandler)`, window_manager, ProviderScope |
| `lib/app.dart` | GoRouter, adaptive shell, recently-played listener, `buildProviderOverrides()` |
| `lib/services/audio/audio_player_service.dart` | Core engine. `onMediaChanged` callback. `isLoading` sync getter. Parallel stop+URL fetch. |
| `lib/services/audio/audio_service_handler.dart` | `aroraAudioHandler` global. `connect()`, `broadcastState()`, `onSongChanged()`. No AudioPlayerService import. |
| `lib/services/audio/playback_queue_notifier.dart` | `playbackQueueProvider` — `playSong`, `playPlaylist`, `next` (wraps), `previous`, `addAllLast` (deduplicates) |
| `lib/services/audio/smart_shuffle_service.dart` | Refills queue when ≤ 3 songs remain. `_recentSeeds` for variety. Fallback alternate seed. |
| `lib/features/player/providers/player_providers.dart` | Creates `audioPlayerServiceProvider`, wires `aroraAudioHandler.connect(...)` |
| `lib/infrastructure/youtube/youtube_explode_music_provider.dart` | Full YouTube impl. Uses muxed streams. Radio Mix `RD{videoId}` for recommendations. |
| `lib/data/datasources/local/hive_database.dart` | Opens all boxes, registers adapters, self-heals stale `.lock` files |
| `lib/features/home/providers/home_providers.dart` | `trendingProvider`, `genreSongsProvider`, `recommendedForYouProvider`, `recentlyPlayedProvider` |
| `lib/shared/utils/bottom_sheet_utils.dart` | `showSongOptionsMenu`, `showAddToPlaylistSheet` — shared bottom sheet helpers |
| `.github/workflows/release.yml` | CI: builds release APK + Linux AppImage on `v*` tag push; creates GitHub Release |

---

## Audio Engine: Queue Lifecycle

1. User taps song → `AudioPlayerService.playQueue()` → `PlaybackQueueNotifier.playPlaylist()`
2. Queue state change → `_ref.listen(playbackQueueProvider, ...)` detects `songChanged || indexChanged` → `_loadAndPlaySong(song)`
3. Song emitted to `_currentSongController` **immediately** (before URL fetch) → NowPlayingScreen renders, lock screen updates
4. `_player.stop()` and `_resolveUrl(song)` run **in parallel** — old audio silenced while new URL is already being fetched
5. `setAudioSource` → `play()`
6. `ProcessingState.completed` → `skipNext()` → `next()` (wraps around), or fetches recommendations if only 1 song queued

**Single-song queue special case:** `next()` on 1 song produces `(0+1)%1 = 0` — identical Riverpod state, listener never fires. `skipNext()` detects this, calls `getRecommendations()` directly, appends with `addAllLast()`, then advances. Race-guard: aborts if user started a different song during the fetch.

## Audio Engine: Media Session / Lock Screen

`aroraAudioHandler` is registered in `AudioService.init` at startup (before Riverpod). After `audioPlayerServiceProvider` creates the service, it calls `aroraAudioHandler.connect(...)`. `AudioPlayerService` fires `onMediaChanged` in two places:
- After `_currentSongController.add(song)` → lock screen artwork/title appear before URL resolves
- Inside `playingStream.listen(...)` → notification play/pause button stays in sync on every toggle

`broadcastState()` sends `AudioProcessingState.loading` while `_isLoading == true`, `ready` while playing, `idle` when paused.

Android permissions required (already in `AndroidManifest.xml`): `WAKE_LOCK`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`. Service has `foregroundServiceType="mediaPlayback"`.

## Audio Engine: Smart Shuffle

Activated by `PlaybackQueueNotifier.toggleSmartShuffle()`.

`SmartShuffleService` listens to `playbackQueueProvider`. When `remaining ≤ 3` songs and shuffle is on:
1. Fetches `getRecommendations(currentSong.id, limit: 15, artistHint: ...)` — Radio Mix `RD{videoId}`
2. Filters against existing queue IDs (dedup handled by `addAllLast`)
3. If primary returns < 3 new songs (Radio Mix exhausted): fetches from `_recentSeeds` — the most recent played song from a **different artist**. This avoids doubling API calls on normal playback while recovering from stale mixes.
4. `_recentSeeds` list (max 5): updated on every queue index advance using `previous.currentSong`

**Rate limiting note:** Alternate seed fetch only happens on exhaustion. Normal playback = 1 API call per refill.

## Audio Engine: Linux

`just_audio_media_kit` bridges to system `libmpv`. Requires `sudo pacman -S mpv`. `JustAudioMediaKit.ensureInitialized(linux: true)` is called at top of `main()`. `AndroidEqualizer`/`AndroidLoudnessEnhancer` are null on Linux — all callers use `?.` access.

**Position stream:** `positionStream` from media_kit updates ~1×/s on Linux. `_ProgressBarWidgetState` compensates with `Timer.periodic(200ms)` polling `audioPlayerServiceProvider.position` directly.

---

## Hive Storage

Storage path: `~/Documents/` (Linux), app documents dir (Android). **No Isar anywhere in this project.**

| Box | Key | Type | TypeAdapter ID |
|---|---|---|---|
| `playlistsBox` | playlist.id | `Playlist` | 1 |
| `downloadsBox` | song.id | `Song` | 0 |
| `settingsBox` | `'settings'` | `Settings` | 3 |
| `searchHistoryBox` | auto-int | `String` | n/a (primitive) |

Rules:
- Never call `Hive.openBox()` directly — all boxes are opened by `HiveDatabase.init()` at startup.
- Access via `Hive.box<T>(HiveDatabase.*BoxName)`.
- Store domain entities (`Song`, `Playlist`) directly. No DTO models.
- `_openBoxSafe<T>()` auto-deletes stale `.lock` files on `FileSystemException`.

---

## Navigation Routes

| Path | Screen | Shell? |
|---|---|---|
| `/` | HomeScreen | Yes |
| `/search` | SearchScreen | Yes |
| `/library` | LibraryScreen | Yes |
| `/downloads` | DownloadsScreen | Yes |
| `/player` | NowPlayingScreen | No (full-screen) |
| `/settings` | SettingsScreen | No |
| `/queue` | QueueScreen | No |
| `/equalizer` | EqualizerScreen | No |
| `/import_playlist` | ImportPlaylistScreen | No |

Shell (`_AdaptiveShell`) uses `BottomNavigationBar` < 800 px, `NavigationRail` ≥ 800 px, rail with labels ≥ 1200 px.

---

## Home Screen Discovery

1. **Trending Now** — `trendingProvider`: playlist `PLFgquLnL59alCl_2TQvOiD5Vgm1hCaGSI`. `keepAlive`.
2. **Because you listened to X** — `recommendedForYouProvider`: uses `ref.read(recentlyPlayedProvider)` (not `ref.watch`) → runs once per home mount, not on every song change. Seeded by `AroraApp.build()` listening to `currentSongProvider`.
3. **Genre rails** — `genreSongsProvider(query)`: Pop Hits, Hip-Hop, Electronic. Waits for `trendingProvider`, then staggers 1.5 s apart. `keepAlive`.

---

## Rate Limiting Mitigations

YouTube enforces per-IP limits on its internal API. Mitigations in place:

| Mitigation | Location |
|---|---|
| Genre searches wait for trending + stagger 1.5 s | `genreSongsProvider` |
| `trendingProvider` + `genreSongsProvider` `keepAlive` (no re-fetch on nav) | `home_providers.dart` |
| `recommendedForYouProvider` uses `ref.read` (once per home mount) | `home_providers.dart` |
| Next-song URL pre-fetch removed from queue listener | `AudioPlayerService` constructor |
| `artistHint` param avoids extra `_yt.videos.get()` in fallback path | `MusicProvider.getRecommendations` |
| `_pendingUrlFetches` dedup — concurrent callers share one in-flight fetch | `AudioPlayerService._resolveUrl` |
| SmartShuffle alternate seed only on Radio Mix exhaustion (< 3 new) | `SmartShuffleService` |

**IP block symptom:** All song taps fail with 403; searches still work. Caused by rapid repeated app restarts (5 YouTube requests per launch). Fix: switch to mobile data or wait 1–2 hours. Not a code bug.

---

## Google OAuth (Phase 1 Complete)

- `YoutubeAuthService` — `signIn()`, `signOut()`, `signInSilently()`, `getAuthenticatedClient()`
- `youtubeAuthServiceProvider` — Riverpod singleton
- `_GoogleAccountTile` in `SettingsScreen` — shows avatar when signed in
- Silent sign-in runs in `main()` before `runApp`
- Android: Firebase project `arora-495906`, SHA-1 registered, `google-services.json` in `android/app/`, test user `celeticcharger@gmail.com` whitelisted in Cloud Console
- Linux: `google_sign_in` has no Linux implementation — silently returns null, app runs as guest

**Phase 2 (optional):** YouTube Music InnerTube migration (`music.youtube.com/youtubei/v1/`) for music-ranked search and real personalisation. See `IMPLEMENTATION_PLAN.md`.

---

## Android Setup

- **Device:** vivo 1920, device ID `a536bde8`, Android 12 (API 31)
- **JDK:** `/opt/android-studio/jbr` (Java 21, bundled with Android Studio) — always set `JAVA_HOME`
- **Gradle:** 8.13 (in `android/gradle/wrapper/gradle-wrapper.properties`)
- **MainActivity:** extends `AudioServiceActivity` (not `FlutterActivity`)
- **Kotlin session dir:** `/usr/lib/flutter/packages/flutter_tools/gradle/.kotlin` must be writable (system Flutter install is read-only — run `sudo chmod -R 777 ...` once)
- **NDK:** 28.2.13676358 (auto-downloaded by Gradle)

---

## Theme System (Session 8)

The design token layer was fully replaced in Session 8.

### New files
| File | Role |
|---|---|
| `lib/core/theme/arora_theme.dart` | `AroraTheme` ThemeExtension — 10-color palette per brightness, shape radii, JSON serialize/deserialize, `toMaterialTheme()` |
| `lib/core/theme/built_in_themes.dart` | 6 built-in themes: Arora Dark, Arora Light, AMOLED Black, Nord, Rosé Pine, Warm Mocha |
| `lib/core/theme/theme_importer.dart` | Import `.arora-theme` JSON via file picker; export to disk; encode/decode custom theme list for Hive |
| `lib/core/theme/app_spacing.dart` | Spacing scale (xs=4 … xxl=48) + touch target sizes + shape radius constants |
| `lib/core/theme/app_motion.dart` | Duration, curve, and SpringDescription constants for all animations |

### AppColors deprecation
`AppColors` static constants are fully deprecated. All UI files now read from `AroraTheme.colors(context)`. The mapping is:
- `AppColors.textSecondaryDark` → `c.textSecondary`
- `AppColors.primary` → `c.accent`
- `AppColors.darkSurface` → `c.surface`
- `AppColors.darkSurfaceElevated` → `c.surfaceRaised`
- `AppColors.success` and `AppColors.error` remain valid semantic constants (still import directly).

### Updated files
| File | What changed |
|---|---|
| `lib/core/theme/app_colors.dart` | New monochromatic token set (10 dark + 10 light). Old constants kept as `@Deprecated` aliases so existing widgets compile during migration |
| `lib/core/theme/app_typography.dart` | Headlines → w800, tight negative letter-spacing; body stays w400 |
| `lib/core/theme/theme_provider.dart` | `themeProvider` now resolves active `AroraTheme` by ID, calls `toMaterialTheme()` for both brightnesses |
| `lib/domain/entities/settings.dart` | Added `@HiveField(2) themeId` and `@HiveField(3) customThemesJson` |
| `lib/services/settings_service.dart` | Added `updateThemeId`, `addCustomTheme`, `removeCustomTheme`, `customThemes` getter |
| `lib/core/theme/settings_screen.dart` | Full redesign: theme gallery (horizontal scroll cards with dark/light swatch preview), import button, theme mode pill |

### Session 8 Steps 2–4: Player UI Redesign

**Step 2 — Mini Player:**
- `lib/features/player/widgets/mini_player_bar.dart` — horizontal swipe gesture with spring physics; `Transform.translate` + `Opacity` visual feedback during drag; swipe left = skip next, right = previous; velocity threshold 500 px/s enables flick-to-skip.

**Step 3 — Now Playing (NowPlayingScreen):**
- `lib/features/player/screens/now_playing_screen.dart` — full redesign; pull-to-dismiss with `SpringSimulation`; `AnimatedSwitcher(key: ValueKey(song.id))` crossfades album art on track change.
- `lib/features/player/widgets/player_controls.dart` — `SpringButton` wrapper for play/pause tap; AroraTheme colors throughout.
- `lib/features/player/widgets/blurred_background.dart` — blurred album art background with gradient overlay.
- `lib/shared/widgets/arora_image.dart` — AroraTheme placeholder, `const Icon` lint fix.

**Step 4 — Gestures & Physics:**
- `AnimationController.unbounded(vsync: this)` paired with `SpringSimulation` (from `flutter/physics.dart`) for velocity-aware spring physics. One persistent `addListener` in `initState` reads `.value` and calls `setState`.
- `AppMotion.swipeSpring = SpringDescription(mass: 1, stiffness: 280, damping: 26)` — ζ ≈ 0.78, ~2% overshoot, settles in ~310 ms.
- `app.dart`: `/player` route uses `CustomTransitionPage` — slides in from bottom (400 ms, decelerate), slides out faster (260 ms, easeIn).
- All 7 `context.go('/player')` calls replaced with `context.push('/player')` (search, library, downloads, queue, trending rail, home).

**Shared widget migrations (Session 8 audit):**
- `lib/shared/widgets/song_tile.dart` — `Flexible` → `Expanded` overflow fix; AroraTheme colors; `Colors.black.withAlpha(115)` instead of deprecated `withOpacity`.
- `lib/shared/widgets/loading_indicator.dart` — removed `AppColors` import; uses `colorScheme.primary`.
- `lib/shared/widgets/album_card.dart` — AroraTheme placeholder and text colors.
- `lib/shared/widgets/error_view.dart` — AroraTheme icon and text colors.
- `lib/features/home/screens/home_screen.dart` — AroraTheme + AppSpacing; search card uses `c.surface` and `t.shapes.sm`.
- `lib/features/library/screens/library_screen.dart` — AroraTheme throughout; `context.go` → `context.push` (2 instances).
- `lib/features/downloads/screens/downloads_screen.dart` — AroraTheme; `context.go` → `context.push`.
- `lib/features/queue/queue_screen.dart` — AroraTheme; `context.go` → `context.push` (2 instances).
- `lib/features/library/screens/import_playlist_screen.dart` — `Colors.green/red` → `AppColors.success/error`; `AroraLoadingIndicator`.

### How widgets consume the theme
```dart
// In any widget:
final t = Theme.of(context).extension<AroraTheme>()!;
final c = t.colors(context); // AroraColors for current brightness
Container(color: c.surface, borderRadius: t.shapes.md);
```

### Theme file format (for third-party theme authors)
```json
{
  "aroraTheme": "1.0",
  "id": "my_theme",
  "name": "My Theme",
  "author": "Your Name",
  "dark":  { "background": 4278190080, "surface": ..., /* 10 int fields */ },
  "light": { "background": 4293519863, ... },
  "shapes": { "radiusSm": 12, "radiusMd": 20, "radiusLg": 28, "radiusXl": 32 }
}
```
Colors are 32-bit ARGB integers (`Color.toARGB32()`). File extension: `.arora-theme`.
Users import via **Settings → Import**.

---

## Feature Status

| Feature | Status |
|---|---|
| Home — Trending, Genre rails, Recommendations | ✅ |
| Search + persistent history | ✅ |
| Audio playback (muxed mp4, 96 kbps AAC) | ✅ |
| Skip next/previous, wrap-around | ✅ |
| Smart Shuffle (Radio Mix + recent seeds) | ✅ |
| Progress bar (200 ms polling) | ✅ |
| Volume control | ✅ |
| Video mode | ✅ Linux; ⚠️ Android (video-only stream 403) |
| Synced lyrics (YouTube captions) | ✅ |
| Create/manage/import playlists | ✅ |
| Download for offline | ✅ |
| Settings (theme, accent, dark/light) | ✅ |
| Equalizer | ✅ Android only (graceful message on Linux) |
| Queue screen | ✅ |
| Google Sign-In | ✅ Android; not supported on Linux |
| Lock screen + notification controls | ✅ Android (confirmed vivo 1920) |
| Song tile overflow | ✅ Fixed (Session 8) — `Flexible` → `Expanded` in subtitle Row |
| Playlist song tap crash | ✅ Fixed (Session 9) — `itemBuilder: (context, i)` shadowed outer context; renamed to `_` |
| Playlist song count stale | ✅ Fixed (Session 9) — `addSong`/`removeSong`/`reorder` now invalidate `playlistsProvider` |
| Song tile `...` menu non-functional | ✅ Fixed (Session 9) — converted to `ConsumerWidget`, wired to `showSongOptionsMenu` |
| Equalizer button in Settings | ⚠️ Route exists but no tile links to it |

---

## Known Limitations

- **Playback latency ~2–4 s** — `getManifest` makes multiple YouTube round-trips. Inherent to unofficial API.
- **Skip latency on 1-song queue ~4–8 s** — recommendations fetch (3–4 s) + URL fetch (3–4 s) sequential. After first skip queue grows; subsequent skips are instant.
- **Audio quality 96 kbps AAC** — muxed stream only; audio-only streams CDN-blocked. Difference audible only on audiophile equipment; bandwidth ~5× higher per song.
- **Offline shuffle** — SmartShuffleService needs network to refill queue.
- **Stream URL TTL ~6 h** — `CacheService` uses `AppConstants.streamUrlTtl`. Long sessions may need fresh URLs.
- **YouTube rate limiting** — mitigated but not eliminated. Per-IP blocks are transient (1–2 h).

---

## Platform Notes

| Platform | Status |
|---|---|
| Linux (x86_64) | ✅ Fully working. Requires `sudo pacman -S mpv`. GTK/ATK warnings on launch are harmless. |
| Android | ✅ Confirmed on vivo 1920 (Android 12, API 31). Zero runtime errors (Sessions 8–9). Open: video-only 403. |
| iOS | Not tested. |
| macOS / Windows | Should work — untested. |
| Web | Partial; `window_manager` / `system_tray` guarded by `isDesktop`. |

---

## AI Agent Rules

### Shared utilities — `lib/shared/utils/`

| File | Exports |
|---|---|
| `bottom_sheet_utils.dart` | `showSongOptionsMenu(context, ref, song, c)` — opens a bottom sheet with "View Queue" and "Add to Playlist" options. `showAddToPlaylistSheet(context, ref, song, c)` — shows the playlist picker. Use these everywhere instead of inline implementations. |

**SongTile** is now a `ConsumerWidget`. Its `...` icon opens `showSongOptionsMenu`. Do not revert to `StatelessWidget`.

### Navigation — CRITICAL
- Always use `context.push('/player')` when navigating to the Now Playing screen. **Never** use `context.go('/player')`.
- `context.go` replaces the entire GoRouter navigation stack. After a `go`, `context.pop()` throws `GoError: There is nothing to pop`, causing a crash in `NowPlayingScreen`'s back button and pull-to-dismiss gesture.
- `context.canPop()` guards are in place in `NowPlayingScreen` as a safety net: `if (context.canPop()) { context.pop(); } else { context.go('/'); }`.
- All 7 song-tap sites that previously used `context.go('/player')` were fixed in Session 8.

### State management
- Use `@riverpod`, `Notifier`, `AsyncNotifier` — never `StateProvider`, `StateNotifierProvider`, `ChangeNotifier`.
- Generated provider = class name minus `Notifier`. `PlaybackQueueNotifier` → `playbackQueueProvider`.
- To call notifier methods: `ref.read(someProvider.notifier).method()`.

### Data models
- Freezed 3.x: `abstract class MyModel with _$MyModel` — NOT `class MyModel`.
- Entities live in `lib/domain/entities/`. No DTOs in domain.

### Local storage
- `hive_ce` only. No Isar.
- Never call `Hive.openBox()` — use `Hive.box<T>(HiveDatabase.*BoxName)` on already-opened boxes.
- Store domain entities directly. No DTO wrappers.

### Music backend
- Never import `YoutubeExplodeMusicProvider` in feature or service code.
- Always use `ref.read(musicProviderProvider)` / `ref.watch(musicProviderProvider)`.

### Audio service
- Playback is driven via `PlaybackQueueNotifier`, not `AudioPlayer` directly.
- `aroraAudioHandler` is the only `BaseAudioHandler`. Register it in `AudioService.init`. Wire via `connect()`.
- Never import `audio_player_service.dart` in `audio_service_handler.dart` — use the callback pattern.
- Always pass `aroraAudioHandler.onSongChanged` as `AudioPlayerService.onMediaChanged`.
- Always pass `artistHint: song.artistName` to `getRecommendations()` — saves a network call.

### Imports to never create
- `player_providers.dart` → `home_providers.dart` — circular via `currentSongProvider`. Recently-played listener belongs in `app.dart`.
- `audio_service_handler.dart` → `audio_player_service.dart` — circular. Use `connect()` callbacks.
- Any feature file → `YoutubeExplodeMusicProvider` — use `musicProviderProvider`.

### Code generation
- After editing any `@freezed` entity or `@riverpod` provider: `dart run build_runner build --delete-conflicting-outputs`.
- Never edit `*.freezed.dart` or `*.g.dart` manually.
- Run `flutter analyze` before considering a task done — must return 0 errors.
