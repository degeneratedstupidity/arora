import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:arora/core/theme/app_motion.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/arora_theme.dart';
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
    // Full-screen player — slides up from the bottom like a modal sheet.
    GoRoute(
      path: '/player',
      name: 'player',
      pageBuilder: (_, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const NowPlayingScreen(),
        transitionDuration: AppMotion.slow,
        reverseTransitionDuration: AppMotion.medium,
        transitionsBuilder: (ctx, animation, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: AppMotion.decelerate,
              reverseCurve: Curves.easeIn,
            ),
          ),
          child: child,
        ),
      ),
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
class _AdaptiveShell extends ConsumerStatefulWidget {
  const _AdaptiveShell({required this.child});
  final Widget child;

  @override
  ConsumerState<_AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends ConsumerState<_AdaptiveShell> {
  bool _sidebarCollapsed = false;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/library')) return 2;
    if (location.startsWith('/downloads')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) => context.go(_tabs[index].path);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _kDesktopBreak;
        final currentIndex = _currentIndex(context);

        return Column(
          children: [
            const WindowTitleBar(),
            Expanded(
              child: isDesktop
                  ? _DesktopLayout(
                      currentIndex: currentIndex,
                      collapsed: _sidebarCollapsed,
                      onTap: (i) => _onTap(context, i),
                      onToggleCollapse: () => setState(
                        () => _sidebarCollapsed = !_sidebarCollapsed,
                      ),
                      child: widget.child,
                    )
                  : _MobileLayout(
                      currentIndex: currentIndex,
                      onTap: (i) => _onTap(context, i),
                      child: widget.child,
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Desktop layout — Echo-style collapsible sidebar
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.child,
    required this.currentIndex,
    required this.collapsed,
    required this.onTap,
    required this.onToggleCollapse,
  });

  final Widget child;
  final int currentIndex;
  final bool collapsed;
  final ValueChanged<int> onTap;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<AroraTheme>()!;
    final c = t.colors(context);
    const expandedWidth = 260.0;
    const collapsedWidth = 80.0;

    return Row(
      children: [
        // ── Echo sidebar ─────────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: collapsed ? collapsedWidth : expandedWidth,
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(
              right: BorderSide(
                color: c.surfaceHighest.withAlpha(60),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Logo + toggle ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 12, 24),
                child: Row(
                  children: [
                    // App logo mark
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c.textPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: c.background,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Arora',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                    // Collapse toggle
                    IconButton(
                      onPressed: onToggleCollapse,
                      icon: Icon(
                        collapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
                        color: c.textSecondary,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Nav items ─────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: _tabs.asMap().entries.map((entry) {
                      final i = entry.key;
                      final tab = entry.value;
                      final isActive = currentIndex == i;
                      return _SidebarNavItem(
                        icon: isActive ? tab.activeIcon : tab.icon,
                        label: tab.label,
                        isActive: isActive,
                        collapsed: collapsed,
                        colors: c,
                        onTap: () => onTap(i),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ── Bottom: Import + mini player ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                child: Column(
                  children: [
                    // Import button
                    _SidebarImportButton(
                      collapsed: collapsed,
                      colors: c,
                      onTap: () => context.push('/import_playlist'),
                    ),
                    const SizedBox(height: 8),
                    // Mini player
                    if (!collapsed) const MiniPlayerBar(),
                  ],
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

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.collapsed,
    required this.colors,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isActive;
  final bool collapsed;
  final AroraColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 14,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? colors.surfaceHighest.withAlpha(180)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            mainAxisAlignment:
                collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? colors.textPrimary : colors.textSecondary,
              ),
              if (!collapsed) ...[
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? colors.textPrimary
                        : colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarImportButton extends StatelessWidget {
  const _SidebarImportButton({
    required this.collapsed,
    required this.colors,
    required this.onTap,
  });
  final bool collapsed;
  final AroraColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.textPrimary.withAlpha(220),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            mainAxisAlignment:
                collapsed ? MainAxisAlignment.center : MainAxisAlignment.center,
            children: [
              Icon(Icons.subscriptions_outlined, size: 16, color: colors.background),
              if (!collapsed) ...[
                const SizedBox(width: 8),
                Text(
                  'Import Library',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.background,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
    final t = Theme.of(context).extension<AroraTheme>()!;
    final c = t.colors(context);

    return Scaffold(
      backgroundColor: c.background,
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player floats above the nav bar with its own padding + shadow.
          // No divider — the pill's shadow creates sufficient separation.
          const MiniPlayerBar(),

          // Navigation bar — colors flow from navigationBarTheme in ThemeData.
          NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            // Shrink height slightly for a tighter feel
            height: 64,
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
