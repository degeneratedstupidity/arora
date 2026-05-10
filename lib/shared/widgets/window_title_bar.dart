import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Custom window title bar for desktop (Linux / macOS / Windows).
///
/// Renders a draggable area with the app name and custom
/// minimize / maximize / close buttons. Hidden on mobile & web.
///
/// Place this at the very top of the [Scaffold] body (inside a [Column]).
class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({super.key});

  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows);

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      // Allow dragging the window by dragging this bar
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            // App icon + title
            Icon(
              Icons.graphic_eq_rounded,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Arora',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
            const Spacer(),
            // Window controls
            _WindowButton(
              icon: Icons.remove_rounded,
              tooltip: 'Minimize',
              onTap: () => windowManager.minimize(),
            ),
            _WindowButton(
              icon: Icons.crop_square_rounded,
              tooltip: 'Maximize',
              onTap: () async {
                if (await windowManager.isMaximized()) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
            ),
            _WindowButton(
              icon: Icons.close_rounded,
              tooltip: 'Close',
              isClose: true,
              onTap: () => windowManager.close(),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  const _WindowButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isClose = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isClose;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hoverColor =
        widget.isClose ? Colors.red.shade700 : colorScheme.onSurface.withValues(alpha: 0.1);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _hovered ? hoverColor : Colors.transparent,
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: _hovered && widget.isClose
                  ? Colors.white
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
