# Arora — Implementation Plan: YouTube Music Login (OAuth + InnerTube)

## Goal

Add Google/YouTube account login so all API requests are authenticated, then migrate
to YouTube Music's InnerTube endpoints for music-specific search, recommendations,
and discovery. This is the same approach used by SimpMusic and InnerTune.

---

## Why This Matters

| Problem today | After this change |
|---|---|
| IP-based rate limiting (`RequestLimitExceededException`) | Eliminated — authenticated sessions are not throttled |
| Generic YouTube video search (not music-optimised) | YouTube Music search (music-ranked results) |
| Staggered/delayed home screen loading (rate limit workaround) | Instant parallel loading |
| Recommendations based on video Radio Mix (`RD{id}`) | YouTube Music's real personalisation algorithm |
| No personal library | Liked songs, user playlists, watch history |
| Standard quality streams | Up to 256 kbps for YouTube Premium users |

**Portfolio value:** OAuth flow + token management + authenticated API integration
is a concrete, hireable engineering skill that goes well beyond scraping.

---

## Reference Project

**SimpMusic** (Kotlin/Jetpack Compose): https://github.com/maxrave-dev/SimpMusic

How it works:
- Reverse-engineers YouTube Music's **InnerTube API** (`music.youtube.com/youtubei/v1/`)
- Supports multi-account YouTube login (token-based, not cookie scraping)
- Uses `ExoPlayer/Media3` for playback (Arora equivalent: `just_audio`)
- Inspired by InnerTune and SmartTube for stream URL extraction

SimpMusic is in the same legal grey area as Arora — unofficial API. The key
distinction: users authenticate with their *own* YouTube account (analogous to
using a third-party email client with your own Gmail), which is a more defensible
position than unauthenticated scraping.

---

## Technical Approach

### Phase 1 — Authenticated `youtube_explode_dart` (fastest path)

`YoutubeExplode` accepts a custom `HttpClient`. An authenticated client eliminates
rate limiting immediately with zero changes to the rest of the codebase.

> **⚠️ Session 6 finding:** Passing an authenticated `googleapis` http.Client into
> `YoutubeExplode` caused HTTP 403 on **all** stream URLs. The library's HEAD validation
> step uses its own internal client (which carries YouTube session cookies) to confirm
> URLs — then external players (mpv, ExoPlayer) fail because they have no such cookies.
> Passing an OAuth `Authorization` header into the InnerTube player endpoint also returns 403.
> The constructor parameter is kept for API compatibility but the client is **not** injected.
> See the Session 6 section at the bottom of this file for full details.

```dart
// lib/infrastructure/youtube/youtube_explode_music_provider.dart
// Current actual implementation — client param accepted but not used:
YoutubeExplodeMusicProvider([http.Client? httpClient])
    : _yt = yt.YoutubeExplode(); // plain unauthenticated client (correct)
```

### Phase 2 — YouTube Music InnerTube endpoints (better quality, optional)

Replace individual method calls in `YoutubeExplodeMusicProvider` with direct
InnerTube calls to `music.youtube.com/youtubei/v1/`. This gives music-ranked
search results, proper charts, and Music-specific recommendations.

Key endpoints:
| Method | InnerTube endpoint |
|---|---|
| `searchSongs` | `POST music.youtube.com/youtubei/v1/search` |
| `getTrending` | `POST music.youtube.com/youtubei/v1/browse` (browseId: `FEmusic_charts`) |
| `getRecommendations` | `POST music.youtube.com/youtubei/v1/next` (with videoId) |
| `getStreamUrl` | `POST music.youtube.com/youtubei/v1/player` |
| `getLyrics` | `POST music.youtube.com/youtubei/v1/next` → lyrics browse token |

All requests share the same InnerTube context payload:
```json
{
  "context": {
    "client": {
      "clientName": "WEB_REMIX",
      "clientVersion": "1.20240101.01.00",
      "hl": "en"
    }
  }
}
```

---

## Implementation Status

| Step | Status | Notes |
|---|---|---|
| Step 1 — pubspec.yaml deps | ✅ Done | `google_sign_in ^6.2.0`, `extension_google_sign_in_as_googleapis_auth ^2.0.0`, `http ^1.6.0` |
| Step 2 — `YoutubeAuthService` | ✅ Done | `lib/infrastructure/auth/youtube_auth_service.dart` |
| Step 3 — `auth_providers.dart` | ✅ Done | `lib/infrastructure/auth/auth_providers.dart` |
| Step 4 — `YoutubeExplodeMusicProvider` | ✅ Done (revised) | Constructor takes `[http.Client? httpClient]` but ignores it — `_yt = yt.YoutubeExplode()`. Passing an authenticated client into `YoutubeExplode` caused 403s on all streams. See Session 6 note below. |
| Step 5 — Wire into `app.dart` + `main.dart` | ✅ Done | `buildProviderOverrides()` function; auth bootstrapped in `main()` |
| Step 6 — Settings UI | ✅ Done | `_GoogleAccountTile` in `settings_screen.dart` |
| Step 7 — Remove rate-limit workarounds | ⏳ Pending | Optional — workarounds are harmless; removing them would only matter if auth was actually reducing request volume (it currently isn't, since the client isn't injected) |
| Step 8 — Android Cloud Console + Firebase setup | ✅ Done | SHA-1 added, `google-services.json` in `android/app/`, Gradle 8.13, JDK 21 (Android Studio bundled) |
| Step 9 — audio_service Android fix | ✅ Done | `MainActivity` → `AudioServiceActivity`; service + receiver in `AndroidManifest.xml` |
| Step 10 — OAuth test user whitelist | ✅ Done | `celeticcharger@gmail.com` added to Cloud Console Test users |
| End-to-end Android test | ✅ Confirmed | Audio (muxed mp4), search, auto-advance, Google Sign-In — all working on vivo 1920 |
| Lock screen / notification controls | ✅ Fixed (Session 7) | `aroraAudioHandler` global singleton wired via `connect()` callbacks; `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_MEDIA_PLAYBACK` permissions added; confirmed on vivo 1920 |
| Smart Shuffle algorithm | ✅ Improved (Session 7) | Threshold 3, batch 15, `_recentSeeds` tracking, fallback different-artist seed; confirmed on vivo 1920 |
| Build verification — Linux | ✅ Passing | `flutter build linux --debug` — 0 errors |
| Build verification — Android | ✅ Passing | `JAVA_HOME=/opt/android-studio/jbr flutter build apk --debug` — ✓ Built `app-debug.apk` |
| `flutter analyze` | ✅ Clean | 0 errors, 0 warnings (pre-existing style infos only) |
| **Open issues** | ⚠️ | `RenderFlex` overflow in `song_tile.dart:48`; video stream 403 on Android |

### Session 6 — CDN Stream Access Discovery (May 2026)

**Root cause of playback failure on all platforms:**
YouTube's CDN serves two classes of streams:
- **Audio-only (opus/webm, itag=251):** Restricted to clients with YouTube session cookies. `youtube_explode_dart` stores these cookies in Dart's `dart:io` HttpClient cookie jar during watch-page responses. External players (mpv, ExoPlayer) have no such cookies → HTTP 403.
- **Muxed (video+audio mp4, itag=18):** Freely accessible to any HTTP client without session credentials.

**What passing an authenticated `googleapis` client into `YoutubeExplode` caused:** The library's HEAD-validation step (`StreamClient.getManifest`) uses its own internal client (with YouTube session cookies) to validate the URL, reporting success (200). The URL then fails when mpv/ExoPlayer try to load it — they have no YouTube cookies.

**Fix applied to `lib/infrastructure/youtube/youtube_explode_music_provider.dart`:**
- Constructor: `YoutubeExplodeMusicProvider([http.Client? httpClient]) : _yt = yt.YoutubeExplode();` (client param kept for API compatibility but not used)
- `getStreamUrl` now uses `manifest.muxed` instead of `manifest.audioOnly`; picks highest-bitrate muxed stream, sorted by kbps
- Trade-off: ~96 kbps AAC vs ~133 kbps Opus; ~5× bandwidth per song; difference audible only on audiophile equipment

**OAuth status:** The `YoutubeAuthService` and `_GoogleAccountTile` UI remain in place. OAuth sign-in is useful for accessing the user's personal YouTube playlists but is **not required** for playback, search, or recommendations.

---

## Step-by-Step Implementation

### Step 1 — `pubspec.yaml` — add dependencies

```yaml
dependencies:
  google_sign_in: ^6.2.0
  extension_google_sign_in_as_googleapis_auth: ^2.0.0
```

`extension_google_sign_in_as_googleapis_auth` converts the `GoogleSignIn` token
into a `http.Client` with the right `Authorization` headers automatically.

---

### Step 2 — Create `lib/infrastructure/auth/youtube_auth_service.dart`

```dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:http/http.dart' as http;

class YoutubeAuthService {
  static const _scopes = [
    'https://www.googleapis.com/auth/youtube.readonly',
  ];

  final _googleSignIn = GoogleSignIn(scopes: _scopes);

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  bool get isSignedIn => _googleSignIn.currentUser != null;

  Future<GoogleSignInAccount?> signIn() => _googleSignIn.signIn();
  Future<void> signOut() => _googleSignIn.signOut();

  /// Returns an authenticated http.Client whose Authorization header is kept
  /// fresh automatically. Pass this to YoutubeExplodeMusicProvider.
  Future<http.Client?> getAuthenticatedClient() async {
    return _googleSignIn.authenticatedClient();
  }

  Future<void> signInSilently() => _googleSignIn.signInSilently();
}
```

---

### Step 3 — Update `YoutubeExplodeMusicProvider` to accept `http.Client`

```dart
// Constructor change only — all methods stay identical
YoutubeExplodeMusicProvider([http.Client? httpClient])
    : _yt = yt.YoutubeExplode(
        httpClient != null
            ? yt.YoutubeHttpClient(httpClient)
            : yt.YoutubeHttpClient(),
      );
```

Falls back to unauthenticated if no client is provided (guest mode).

---

### Step 4 — Wire auth into `lib/app.dart`

```dart
// In AroraApp.build() or initState:
final authService = YoutubeAuthService();
await authService.signInSilently(); // restore previous session on launch

final httpClient = await authService.getAuthenticatedClient();
final musicProvider = YoutubeExplodeMusicProvider(httpClient);

// Existing provider override — no other change needed
final providerOverrides = [
  musicProviderProvider.overrideWith((ref) {
    ref.onDispose(musicProvider.dispose);
    return musicProvider;
  }),
];
```

---

### Step 5 — Add sign-in UI in `SettingsScreen`

```dart
// lib/features/settings/screens/settings_screen.dart
// Add below existing settings tiles:

Consumer(builder: (context, ref, _) {
  final authService = ref.watch(youtubeAuthServiceProvider);
  final user = authService.currentUser;

  if (user != null) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(user.photoUrl ?? '')),
      title: Text(user.displayName ?? 'YouTube Account'),
      subtitle: const Text('Tap to sign out'),
      onTap: () async {
        await authService.signOut();
        ref.invalidate(youtubeAuthServiceProvider);
      },
    );
  }

  return ListTile(
    leading: const Icon(Icons.account_circle_outlined),
    title: const Text('Sign in with Google'),
    subtitle: const Text('Removes rate limits · unlocks personal library'),
    onTap: () async {
      await authService.signIn();
      ref.invalidate(youtubeAuthServiceProvider);
    },
  );
}),
```

---

### Step 6 — Platform setup (required before testing)

**Android** (`android/` folder):
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project → Enable **YouTube Data API v3**
3. Create OAuth 2.0 credentials → Android client ID
4. Add SHA-1 of debug keystore: `keytool -list -v -keystore ~/.android/debug.keystore`
5. Download `google-services.json` → place in `android/app/`
6. Add to `android/app/build.gradle`: `apply plugin: 'com.google.gms.google-services'`

**Linux (Desktop)**:
`google_sign_in` on Linux requires the OAuth2 device-flow or a local redirect URI.
Options:
- Use `google_sign_in_desktop` package (community, check pub.dev)
- Manual OAuth2 via `dart:io` HTTP server listening on `localhost:PORT` for the redirect
- For now: guest mode (unauthenticated) works on Linux; login available on Android

---

### Step 7 — Remove rate limiting workarounds (after auth confirmed working)

These were added to work around unauthenticated rate limits. With auth, they can
be simplified or removed:

| Workaround | After auth | File |
|---|---|---|
| Stagger delays in genre providers (`Future.delayed`) | Remove — load in parallel | `home_providers.dart` |
| `try { await trendingProvider.future }` gate | Remove | `home_providers.dart` |
| `artistHint` parameter | Keep — still saves a network call | `MusicProvider` interface |
| `_pendingUrlFetches` deduplication | Keep — still useful regardless | `AudioPlayerService` |
| `ref.keepAlive()` on providers | Keep — good practice | `home_providers.dart` |

---

## Files to Create / Modify

| File | Action |
|---|---|
| `pubspec.yaml` | Add `google_sign_in`, `extension_google_sign_in_as_googleapis_auth` |
| `lib/infrastructure/auth/youtube_auth_service.dart` | **New** — auth service |
| `lib/infrastructure/auth/auth_providers.dart` | **New** — Riverpod provider for auth service |
| `lib/infrastructure/youtube/youtube_explode_music_provider.dart` | Accept optional `http.Client` |
| `lib/app.dart` | Init auth on launch, pass client to provider |
| `lib/features/settings/screens/settings_screen.dart` | Add sign-in tile |
| `lib/features/home/providers/home_providers.dart` | Remove stagger delays (Step 7) |
| `android/app/` | Add `google-services.json` |
| `android/app/build.gradle` | Apply google-services plugin |

---

## Phase 2 — YouTube Music InnerTube (after Phase 1 is working)

Once OAuth is confirmed working, optionally create a new provider:

```
lib/infrastructure/youtube_music/
├── youtube_music_provider.dart    # new MusicProvider impl
├── innertube_client.dart          # raw InnerTube HTTP client
├── models/                        # InnerTube response models
│   ├── search_result.dart
│   ├── browse_result.dart
│   └── player_response.dart
└── parsers/                       # JSON → Song/Album/Lyrics
    ├── search_parser.dart
    └── player_parser.dart
```

Switch `lib/app.dart` to use `YoutubeMusicProvider` instead of
`YoutubeExplodeMusicProvider`. All UI and service code stays identical (MusicProvider
interface is unchanged).

---

## Estimated Effort

| Task | Time |
|---|---|
| Step 1–4 (auth + injection) | ~4 hours |
| Step 5 (UI) | ~1 hour |
| Step 6 (Android/Cloud Console) | ~1 hour |
| Step 7 (cleanup) | ~30 min |
| Testing | ~2 hours |
| **Phase 1 total** | **~1 day** |
| Phase 2 (InnerTube migration) | ~2-3 days |
