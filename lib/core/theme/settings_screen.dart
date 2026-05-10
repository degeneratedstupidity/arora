import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/domain/entities/settings.dart';
import 'package:arora/infrastructure/auth/auth_providers.dart';
import 'package:arora/services/settings_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // A curated list of material accent colors
  static const List<Color> _accentColors = [
    Color(0xFF007ACC), // Default Blue
    Color(0xFFE53935), // Red
    Color(0xFF43A047), // Green
    Color(0xFF8E24AA), // Purple
    Color(0xFFFFB300), // Amber
    Color(0xFF00ACC1), // Cyan
    Color(0xFF3949AB), // Indigo
    Color(0xFFF4511E), // Deep Orange
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);
    final settingsNotifier = ref.read(settingsServiceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),
          const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<AppThemeMode>(
            segments: const [
              ButtonSegment(
                value: AppThemeMode.system,
                icon: Icon(Icons.brightness_auto),
                label: Text('System'),
              ),
              ButtonSegment(
                value: AppThemeMode.light,
                icon: Icon(Icons.light_mode),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: AppThemeMode.dark,
                icon: Icon(Icons.dark_mode),
                label: Text('Dark'),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (Set<AppThemeMode> newSelection) {
              settingsNotifier.updateThemeMode(newSelection.first);
            },
          ),
          const SizedBox(height: 24),
          const Text('Accent Color', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _accentColors.map((color) {
              final isSelected = settings.accentColorValue == color.toARGB32();
              return GestureDetector(
                onTap: () => settingsNotifier.updateAccentColor(color.toARGB32()),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 3,
                          )
                        : null,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Audio', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: const Text('Equalizer'),
            onTap: () => context.push('/equalizer'),
          ),
          const SizedBox(height: 24),
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          _GoogleAccountTile(),
        ],
      ),
    );
  }
}

/// Sign-in / sign-out tile for the Google account section.
///
/// Signing in injects an authenticated http.Client into YoutubeExplode which
/// eliminates YouTube's per-IP rate limiting. The new client takes effect on
/// the next app launch (hot restart not required for the sign-in state itself,
/// but the provider is initialized at startup).
class _GoogleAccountTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(youtubeAuthServiceProvider);
    final user = authService.currentUser;

    if (user != null) {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? const Icon(Icons.person_rounded)
              : null,
        ),
        title: Text(user.displayName ?? 'YouTube Account'),
        subtitle: Text(user.email),
        trailing: TextButton(
          child: const Text('Sign out'),
          onPressed: () async {
            await authService.signOut();
            ref.invalidate(youtubeAuthServiceProvider);
          },
        ),
      );
    }

    return ListTile(
      leading: const Icon(Icons.account_circle_outlined),
      title: const Text('Sign in with Google'),
      subtitle: const Text('Removes rate limits · unlocks personal library'),
      onTap: () async {
        final account = await authService.signIn();
        if (account != null) {
          ref.invalidate(youtubeAuthServiceProvider);
        }
      },
    );
  }
}