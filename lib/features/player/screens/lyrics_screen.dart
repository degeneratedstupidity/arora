import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/core/theme/arora_theme.dart';
import 'package:arora/domain/entities/lyrics.dart';
import 'package:arora/domain/usecases/get_lyrics_usecase.dart';
import 'package:arora/features/player/providers/player_providers.dart';

final lyricsProvider = FutureProvider.autoDispose<Lyrics?>((ref) async {
  final song = ref.watch(currentSongProvider).value;
  if (song == null) return null;
  final useCase = GetLyricsUseCase(ref.watch(musicProviderProvider));
  return useCase(song.id);
});

class LyricsView extends ConsumerStatefulWidget {
  const LyricsView({super.key});

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView> {
  final _scrollController = ScrollController();
  int _currentLineIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _activeIndex(List<LyricLine> lines, Duration position) {
    final ms = position.inMilliseconds;
    var idx = 0;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startMs <= ms) idx = i;
    }
    return idx;
  }

  @override
  Widget build(BuildContext context) {
    final lyricsAsync = ref.watch(lyricsProvider);
    final position = ref.watch(playbackPositionProvider).value;

    return lyricsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).extension<AroraTheme>()!.colors(context).accent,
        ),
      ),
      error: (_, __) => const _NoLyricsState(),
      data: (lyrics) {
        if (lyrics == null || !lyrics.hasContent) return const _NoLyricsState();

        if (lyrics.isSynced && position != null) {
          final newIndex = _activeIndex(lyrics.timedLines, position);
          if (newIndex != _currentLineIndex) {
            _currentLineIndex = newIndex;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_scrollController.hasClients) return;
              _scrollController.animateTo(
                (newIndex * 56.0).clamp(0, _scrollController.position.maxScrollExtent),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          }
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            itemCount: lyrics.timedLines.length,
            itemBuilder: (context, i) => _LyricLineWidget(
              text: lyrics.timedLines[i].text,
              isActive: i == _currentLineIndex,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Text(
            lyrics.plainText ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).extension<AroraTheme>()!.colors(context).textSecondary,
                  height: 1.8,
                ),
          ),
        );
      },
    );
  }
}

class _LyricLineWidget extends StatelessWidget {
  const _LyricLineWidget({required this.text, required this.isActive});
  final String text;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AroraTheme>()!.colors(context);
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: isActive
          ? Theme.of(context).textTheme.titleMedium!.copyWith(
                color: c.accent,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              )
          : Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: c.textSecondary.withAlpha(180),
              ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}

class _NoLyricsState extends StatelessWidget {
  const _NoLyricsState();
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AroraTheme>()!.colors(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lyrics_outlined, size: 48, color: c.textSecondary),
          const SizedBox(height: 12),
          Text(
            'No lyrics available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
