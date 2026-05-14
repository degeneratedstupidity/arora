import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/core/theme/app_spacing.dart';
import 'package:arora/core/theme/built_in_themes.dart';
import 'package:arora/core/theme/theme_importer.dart';
import 'package:arora/core/theme/theme_provider.dart';
import 'package:arora/domain/entities/settings.dart';
import 'package:arora/infrastructure/auth/auth_providers.dart';
import 'package:arora/services/settings_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);
    final notifier = ref.read(settingsServiceProvider.notifier);
    final aroraTheme = ref.watch(activeAroraThemeProvider);
    final c = aroraTheme.colors(context);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          // ── Appearance ────────────────────────────────────────────────────
          _SectionHeader(label: 'Appearance', colors: c),

          // Theme mode pill
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: _ThemeModeSelector(
              current: settings.themeMode,
              colors: c,
              onChanged: notifier.updateThemeMode,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Theme gallery label + import button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Text(
                  'Theme',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: c.textSecondary),
                ),
                const Spacer(),
                _ImportButton(colors: c),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Built-in themes
          _ThemeGallery(
            themes: BuiltInThemes.all,
            activeId: settings.themeId,
            colors: c,
            onSelect: (id) => notifier.updateThemeId(id),
            onDelete: null, // built-ins cannot be deleted
          ),

          // Custom imported themes (if any)
          if (notifier.customThemes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Imported',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: c.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ThemeGallery(
              themes: notifier.customThemes,
              activeId: settings.themeId,
              colors: c,
              onSelect: (id) => notifier.updateThemeId(id),
              onDelete: (id) => notifier.removeCustomTheme(id),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // ── Audio ──────────────────────────────────────────────────────────
          _SectionHeader(label: 'Audio', colors: c),
          _SettingsTile(
            icon: Icons.tune_rounded,
            label: 'Equalizer',
            colors: c,
            onTap: () => context.push('/equalizer'),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Account ────────────────────────────────────────────────────────
          _SectionHeader(label: 'Account', colors: c),
          _GoogleAccountTile(colors: c),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.colors});
  final String label;
  final AroraColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs,),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.textTertiary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

// ── Theme mode selector ───────────────────────────────────────────────────────

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({
    required this.current,
    required this.colors,
    required this.onChanged,
  });
  final AppThemeMode current;
  final AroraColors colors;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          _ModeTab(
            icon: Icons.brightness_auto_rounded,
            label: 'System',
            selected: current == AppThemeMode.system,
            colors: colors,
            onTap: () => onChanged(AppThemeMode.system),
          ),
          _ModeTab(
            icon: Icons.light_mode_rounded,
            label: 'Light',
            selected: current == AppThemeMode.light,
            colors: colors,
            onTap: () => onChanged(AppThemeMode.light),
          ),
          _ModeTab(
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            selected: current == AppThemeMode.dark,
            colors: colors,
            onTap: () => onChanged(AppThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final AroraColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.surfaceHighest : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm - 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? colors.textPrimary : colors.textTertiary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? colors.textPrimary : colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Import button ─────────────────────────────────────────────────────────────

class _ImportButton extends ConsumerWidget {
  const _ImportButton({required this.colors});
  final AroraColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final result = await ThemeImporter.pickAndImport(context);
        if (result == null) return;
        if (result.error.isNotEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result.error)),
            );
          }
          return;
        }
        await ref
            .read(settingsServiceProvider.notifier)
            .addCustomTheme(result.theme);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${result.theme.name}" imported'),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs,),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_file_rounded, size: 16, color: colors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Import',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Theme gallery ─────────────────────────────────────────────────────────────

class _ThemeGallery extends ConsumerWidget {
  const _ThemeGallery({
    required this.themes,
    required this.activeId,
    required this.colors,
    required this.onSelect,
    required this.onDelete,
  });

  final List<AroraTheme> themes;
  final String activeId;
  final AroraColors colors;
  final ValueChanged<String> onSelect;
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: themes.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final t = themes[i];
          final isActive = t.id == activeId;
          return _ThemeCard(
            theme: t,
            isActive: isActive,
            parentColors: colors,
            onTap: () => onSelect(t.id),
            onDelete: onDelete != null ? () => onDelete!(t.id) : null,
          );
        },
      ),
    );
  }
}

// ── Theme card ────────────────────────────────────────────────────────────────

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.isActive,
    required this.parentColors,
    required this.onTap,
    this.onDelete,
  });

  final AroraTheme theme;
  final bool isActive;
  final AroraColors parentColors;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    // Preview uses the dark variant regardless of current mode so all cards
    // are visually distinct and consistent in the gallery row.
    final dc = theme.darkColors;
    final lc = theme.lightColors;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 110,
        decoration: BoxDecoration(
          color: parentColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isActive ? parentColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Color swatch preview ─────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMd - 2),
                ),
                child: Row(
                  children: [
                    // Dark half
                    Expanded(
                      child: Container(
                        color: dc.background,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Mini play button swatch
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: dc.playButtonBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  size: 13,
                                  color: dc.playButtonFg,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Accent bar
                              Container(
                                width: 30,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: dc.accent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Light half
                    Expanded(
                      child: Container(
                        color: lc.background,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: lc.playButtonBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  size: 13,
                                  color: lc.playButtonFg,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: 30,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: lc.accent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Theme name ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
              child: Text(
                theme.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? parentColors.textPrimary
                      : parentColors.textSecondary,
                ),
              ),
            ),
            if (theme.author != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                child: Text(
                  theme.author!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: parentColors.textTertiary,
                  ),
                ),
              )
            else
              const SizedBox(height: 6),

            // Active check
            if (isActive)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: parentColors.accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Generic settings tile ─────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final AroraColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: Icon(icon, color: colors.textSecondary, size: 22),
      title: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: colors.textPrimary),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colors.textTertiary,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}

// ── Google account tile ───────────────────────────────────────────────────────

class _GoogleAccountTile extends ConsumerWidget {
  const _GoogleAccountTile({required this.colors});
  final AroraColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(youtubeAuthServiceProvider);
    final user = authService.currentUser;

    if (user != null) {
      return ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        leading: CircleAvatar(
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          backgroundColor: colors.surfaceRaised,
          child: user.photoUrl == null
              ? Icon(Icons.person_rounded, color: colors.textSecondary)
              : null,
        ),
        title: Text(
          user.displayName ?? 'YouTube Account',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: colors.textPrimary),
        ),
        subtitle: Text(
          user.email,
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
        ),
        trailing: TextButton(
          onPressed: () async {
            await authService.signOut();
            ref.invalidate(youtubeAuthServiceProvider);
          },
          style: TextButton.styleFrom(foregroundColor: colors.textSecondary),
          child: const Text('Sign out'),
        ),
      );
    }

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: Icon(Icons.account_circle_outlined, color: colors.textSecondary),
      title: Text(
        'Sign in with Google',
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: colors.textPrimary),
      ),
      subtitle: Text(
        'Removes rate limits · unlocks personal library',
        style: TextStyle(color: colors.textSecondary, fontSize: 12),
      ),
      onTap: () async {
        final account = await authService.signIn();
        if (account != null) {
          ref.invalidate(youtubeAuthServiceProvider);
        }
      },
    );
  }
}
