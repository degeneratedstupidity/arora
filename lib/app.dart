import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:arora/core/theme/theme_provider.dart';
import 'package:arora/features/downloads/screens/downloads_screen.dart';
import 'package:arora/features/home/screens/home_screen.dart';
import 'package:arora/features/library/screens/library_screen.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/features/player/screens/now_playing_screen.dart';
import 'package:arora/features/player/widgets/mini_player_bar.dart';
import 'package:arora/features/search/screens/search_screen.dart';
import 'package:arora/infrastructure/youtube/youtube_explode_music_provider.dart';
import 'package:arora/shared/widgets/window_title_bar.dart';

import 'package:arora/core/theme/settings_screen.dart';
import 'package:arora/features/home/providers/home_providers.dart';
import 'package:arora/features/queue/queue_screen.dart';
import 'package:arora/features/settings/equalizer_screen.dart';
import 'package:arora/features/library/screens/import_playlist_screen.dart';

// ---------------------------------------------------------------------------
// Dependency Injection
// ---------------------------------------------------------------------------

/// Builds the Riverpod override list for [ProviderScope].
///
/// Called from [main] after the auth bootstrap so an authenticated [http.Client]
/// can be injected. Passing null falls back to unauthenticated (guest) mode.
///
/// Switching music backends: change [YoutubeExplodeMusicProvider] here only.
// Returns a List<Override> — type not annotated because Override is not
// exported from flutter_riverpod's public API in v3.x.
// ignore: always_declare_return_types
buildProviderOverrides({http.Client? httpClient}) {
  final youtubeProvider = YoutubeExplodeMusicProvider(httpClient);
  return [
    musicProviderProvider.overrideWith((ref) {
      ref.onDispose(youtubeProvider.dispose);
      return youtubeProvider;
    }),
  ];
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

// Width breakpoints — kept in sync with main_shell.dart
const _kDesktopBreak = 800.0;
const _kWideDesktopBreak = 1200.0;

/// The global GoRouter instance with all named routes.
final _router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
  routes: [
    // ── Shell route: wraps all main screens with adaptive nav + MiniPlayer
    ShellRoute(
      builder: (context, state, child) => _AdaptiveShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (_, __) => const SearchScreen(),
        ),
        GoRoute(
          path: '/library',
          name: 'library',
          builder: (_, __) => const LibraryScreen(),
        ),
        GoRoute(
          path: '/downloads',
          name: 'downloads',
          builder: (_, __) => const DownloadsScreen(),
        ),
      ],
    ),
    // Full-screen player — no bottom nav or mini player
    GoRoute(
      path: '/player',
      name: 'player',
      builder: (_, __) => const NowPlayingScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (_, __) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/queue',
      name: 'queue',
      builder: (_, __) => const QueueScreen(),
    ),
    GoRoute(
      path: '/equalizer',
      name: 'equalizer',
      builder: (_, __) => const EqualizerScreen(),
    ),
    GoRoute(
      path: '/import_playlist',
      name: 'import_playlist',
      builder: (_, __) => const ImportPlaylistScreen(),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Global Keyboard Intents
// ---------------------------------------------------------------------------

class PlayPauseIntent extends Intent {
  const PlayPauseIntent();
}

class SkipNextIntent extends Intent {
  const SkipNextIntent();
}

class SkipPreviousIntent extends Intent {
  const SkipPreviousIntent();
}

// ---------------------------------------------------------------------------
// Root App Widget
// ---------------------------------------------------------------------------

class AroraApp extends ConsumerWidget {
  const AroraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeProvider);

    // Track every song change so the Home screen can show "Because you
    // listened to X" recommendations and recently played history.
    ref.listen(currentSongProvider, (_, next) {
      if (next.hasValue && next.value != null) {
        ref.read(recentlyPlayedProvider.notifier).add(next.value!);
      }
    });

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        // Hardware Media Keys
        SingleActivator(LogicalKeyboardKey.mediaPlayPause): PlayPauseIntent(),
        SingleActivator(LogicalKeyboardKey.mediaTrackNext): SkipNextIntent(),
        SingleActivator(LogicalKeyboardKey.mediaTrackPrevious):
            SkipPreviousIntent(),
        // Keyboard Combos (Ctrl/Cmd + Arrows)
        SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
            SkipNextIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight, meta: true):
            SkipNextIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
            SkipPreviousIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft, meta: true):
            SkipPreviousIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PlayPauseIntent: CallbackAction<PlayPauseIntent>(
            onInvoke: (_) =>
                ref.read(audioPlayerServiceProvider).togglePlayPause(),
          ),
          SkipNextIntent: CallbackAction<SkipNextIntent>(
            onInvoke: (_) => ref.read(audioPlayerServiceProvider).skipNext(),
          ),
          SkipPreviousIntent: CallbackAction<SkipPreviousIntent>(
            onInvoke: (_) =>
                ref.read(audioPlayerServiceProvider).skipPrevious(),
          ),
        },
        child: MaterialApp.router(
          title: 'Arora',
          debugShowCheckedModeBanner: false,
          theme: appTheme.light,
          darkTheme: appTheme.dark,
          themeMode: appTheme.mode,
          routerConfig: _router,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Adaptive Shell — responds to screen width
// ---------------------------------------------------------------------------

typedef _NavTab = ({
  String path,
  IconData icon,
  IconData activeIcon,
  String label
});

const _tabs = <_NavTab>[
  (
    path: '/',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home'
  ),
  (
    path: '/search',
    icon: Icons.search_outlined,
    activeIcon: Icons.search_rounded,
    label: 'Search'
  ),
  (
    path: '/library',
    icon: Icons.library_music_outlined,
    activeIcon: Icons.library_music_rounded,
    label: 'Library'
  ),
  (
    path: '/downloads',
    icon: Icons.download_outlined,
    activeIcon: Icons.download_rounded,
    label: 'Downloads'
  ),
];

/// Persistent scaffold that swaps between mobile + desktop layouts.
class _AdaptiveShell extends ConsumerWidget {
  const _AdaptiveShell({required this.child});
  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/library')) return 2;
    if (location.startsWith('/downloads')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) => context.go(_tabs[index].path);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _kDesktopBreak;
        final isWide = constraints.maxWidth >= _kWideDesktopBreak;
        final currentIndex = _currentIndex(context);

        return Column(
          children: [
            // Frameless custom title bar (desktop only, hidden on mobile/web)
            const WindowTitleBar(),
            Expanded(
              child: isDesktop
                  ? _DesktopLayout(
                      currentIndex: currentIndex,
                      extended: isWide,
                      onTap: (i) => _onTap(context, i),
                      child: child,
                    )
                  : _MobileLayout(
                      currentIndex: currentIndex,
                      onTap: (i) => _onTap(context, i),
                      child: child,
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Desktop layout — NavigationRail + optional expanded sidebar
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.child,
    required this.currentIndex,
    required this.extended,
    required this.onTap,
  });

  final Widget child;
  final int currentIndex;
  final bool extended;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // ── Sidebar / Rail ───────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: NavigationRail(
                  extended: extended,
                  selectedIndex: currentIndex,
                  onDestinationSelected: onTap,
                  backgroundColor: Colors.transparent,
                  indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
                  selectedIconTheme: IconThemeData(color: colorScheme.primary),
                  selectedLabelTextStyle: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  destinations: _tabs
                      .map(
                        (t) => NavigationRailDestination(
                          icon: Icon(t.icon),
                          selectedIcon: Icon(t.activeIcon),
                          label: Text(t.label),
                        ),
                      )
                      .toList(),
                ),
              ),
              // Mini player at the bottom of the sidebar
              if (extended)
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 12),
                  child: MiniPlayerBar(),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: IconButton(
                    icon: const Icon(Icons.queue_music_rounded),
                    tooltip: 'Now Playing',
                    color: colorScheme.primary,
                    onPressed: () => context.push('/player'),
                  ),
                ),
            ],
          ),
        ),

        // ── Main content ─────────────────────────────────────────────────
        Expanded(child: child),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile layout — standard bottom NavigationBar + MiniPlayer above it
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.child,
    required this.currentIndex,
    required this.onTap,
  });

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerBar(),
          NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            destinations: _tabs
                .map(
                  (t) => NavigationDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.activeIcon),
                    label: t.label,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
