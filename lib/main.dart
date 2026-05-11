import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:arora/app.dart';
import 'package:arora/data/datasources/local/hive_database.dart';
import 'package:arora/infrastructure/auth/auth_providers.dart';
import 'package:arora/infrastructure/auth/youtube_auth_service.dart';
import 'package:arora/services/audio/audio_service_handler.dart';

/// Entry point for Arora.
///
/// ## Bootstrap order
/// 1. [flutter_dotenv] — load `.env` secrets
/// 2. [HiveDatabase.init] — open Hive boxes and register TypeAdapters
/// 3. [audio_service] — register [AudioServiceHandler] for background audio
/// 4. [window_manager] — configure frameless desktop window (desktop only)
/// 5. [ProviderScope] — Riverpod DI container
/// 6. [AroraApp] — widget tree
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register just_audio_media_kit as the audio backend for desktop/Linux.
  JustAudioMediaKit.ensureInitialized(
    linux: true,
    windows: true,
    macOS: true,
    android: false,
    iOS: false,
  );

  // 1. Load .env
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env is optional — features requiring keys surface missing values gracefully.
  }

  // 2. Initialise Hive — must happen before any box is accessed.
  try {
    await HiveDatabase.init();
  } catch (e) {
    // Non-fatal: offline library/downloads/settings won't work, but playback will.
    debugPrint('[Arora] Hive init failed: $e');
  }

  // 2.5. Auth — restore previous Google session silently.
  // On unsupported platforms (Linux desktop) both calls return null gracefully;
  // the app continues in guest/unauthenticated mode without throwing.
  final authService = YoutubeAuthService();
  http.Client? authClient;
  try {
    await authService.signInSilently();
    authClient = await authService.getAuthenticatedClient();
    if (authClient != null) {
      debugPrint('[Arora] Google sign-in restored — authenticated requests active');
    } else {
      debugPrint('[Arora] No saved session — running in guest mode');
    }
  } catch (e) {
    debugPrint('[Arora] Auth init error (guest mode): $e');
  }

  // 3. Register the real AudioServiceHandler with audio_service.
  //    aroraAudioHandler is a global singleton defined in audio_service_handler.dart.
  //    Its callbacks are wired to AudioPlayerService later in player_providers.dart
  //    after Riverpod initialises, so there is no circular dependency.
  await AudioService.init(
    builder: () => aroraAudioHandler,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.arora.audio',
      androidNotificationChannelName: 'Arora Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  // 4. Desktop window setup (frameless, custom title bar).
  final isDesktop = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows);
  if (isDesktop) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(1100, 700),
        minimumSize: Size(480, 640),
        center: true,
        titleBarStyle: TitleBarStyle.hidden,
        windowButtonVisibility: false,
        title: 'Arora',
        backgroundColor: Colors.transparent,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
    
    // System tray disabled for v1.0 compilation stability
  }

  // 5 & 6. Launch app — inject authenticated client (or null for guest mode).
  runApp(
    ProviderScope(
      overrides: [
        youtubeAuthServiceProvider.overrideWithValue(authService),
        ...buildProviderOverrides(httpClient: authClient),
      ],
      child: const AroraApp(),
    ),
  );
}

