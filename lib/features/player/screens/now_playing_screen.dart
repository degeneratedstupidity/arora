import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/domain/usecases/get_video_url_usecase.dart';
import 'package:arora/features/downloads/providers/download_providers.dart';
import 'package:arora/features/library/providers/library_providers.dart';
import 'package:arora/features/player/providers/player_providers.dart';
import 'package:arora/features/player/screens/lyrics_screen.dart';
import 'package:arora/features/player/widgets/player_controls.dart';
import 'package:arora/shared/widgets/loading_indicator.dart';
import 'package:arora/features/player/widgets/blurred_background.dart';
import 'package:arora/shared/widgets/arora_image.dart';
import 'package:arora/shared/widgets/error_view.dart';

/// The full-screen Now Playing screen.
///
/// Features:
/// - Album art (audio mode) or inline video (video mode)
/// - Audio/Video mode toggle (only when song.hasVideo == true)
/// - Full player controls + progress bar
/// - Lyrics panel (slide-up bottom sheet)
/// - Download button
/// - Queue bottom sheet
class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songAsync = ref.watch(currentSongProvider);

    return songAsync.when(
      loading: () => const Scaffold(body: AroraLoadingIndicator()),
      error: (e, _) => Scaffold(body: ErrorView(message: '$e')),
      data: (song) {
        if (song == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.music_off_rounded,
                      size: 64, color: AppColors.textSecondaryDark,),
                  const SizedBox(height: 16),
                  const Text('Nothing playing'),
                  const SizedBox(height: 24),
                  FilledButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Browse Music'),),
                ],
              ),
            ),
          );
        }

        final playerMode = ref.watch(playerModeProvider);

        return Scaffold(
          body: Stack(
            children: [
              BlurredBackground(imageUrl: song.thumbnailUrl),
              SafeArea(
                child: Column(
                  children: [
                    // ── Top bar ───────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4,),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                size: 32,),
                            onPressed: () => context.go('/'),
                          ),
                          const Spacer(),
                          Text('Now Playing',
                              style: Theme.of(context).textTheme.titleSmall,),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.more_vert_rounded),
                            onPressed: () =>
                                _showOptionsMenu(context, ref, song),
                          ),
                        ],
                      ),
                    ),

                    // ── Audio/Video toggle (only when hasVideo) ───────────────
                    if (song.hasVideo)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 4,),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ModeTab(
                                label: '🎵 Audio',
                                isSelected: playerMode == PlayerMode.audio,
                                onTap: () => ref
                                    .read(playerModeProvider.notifier)
                                    .update(PlayerMode.audio),
                              ),
                              _ModeTab(
                                label: '🎬 Video',
                                isSelected: playerMode == PlayerMode.video,
                                onTap: () => ref
                                    .read(playerModeProvider.notifier)
                                    .update(PlayerMode.video),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Art / Video area ──────────────────────────────────────
                    Expanded(
                      child: playerMode == PlayerMode.video && song.hasVideo
                          ? _VideoView(songId: song.videoId ?? song.id)
                          : _AudioArtView(song: song),
                    ),

                    // ── Song info ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  song.artistName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondaryDark,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          // Download button
                          _DownloadButton(song: song),
                        ],
                      ),
                    ),

                    // ── Player controls + progress bar ────────────────────────
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 12, 0, 8),
                      child: PlayerControls(),
                    ),

                    // ── Lyrics button ─────────────────────────────────────────
                    TextButton.icon(
                      onPressed: () => _showLyricsSheet(context),
                      icon: const Icon(Icons.lyrics_outlined, size: 18),
                      label: const Text('Lyrics'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondaryDark,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLyricsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceElevated,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Lyrics', style: Theme.of(context).textTheme.titleMedium),
            const Expanded(child: LyricsView()),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref, Song song) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.queue_music_rounded),
            title: const Text('View Queue'),
            onTap: () {
              Navigator.pop(context);
              context.push('/queue');
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add_rounded),
            title: const Text('Add to Playlist'),
            onTap: () {
              Navigator.pop(context);
              _showAddToPlaylistSheet(context, ref, song);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, WidgetRef ref, Song song) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer(
        builder: (_, ref, __) {
          final playlistsAsync = ref.watch(playlistsProvider);
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add to Playlist',
                    style: Theme.of(context).textTheme.titleMedium,),
                const SizedBox(height: 8),
                playlistsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: AroraLoadingIndicator(),
                  ),
                  error: (_, __) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Could not load playlists.'),
                  ),
                  data: (playlists) {
                    if (playlists.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No playlists yet.\nCreate one in the Library tab first.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondaryDark),
                        ),
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: playlists
                          .map(
                            (pl) => ListTile(
                              leading: const Icon(Icons.queue_music_rounded,
                                  color: AppColors.primary,),
                              title: Text(pl.title),
                              subtitle: Text('${pl.songs.length} songs',
                                  style: const TextStyle(
                                      color: AppColors.textSecondaryDark,),),
                              onTap: () async {
                                Navigator.pop(ctx);
                                await ref
                                    .read(playlistNotifierProvider.notifier)
                                    .addSong(pl.id, song);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Added "${song.title}" to ${pl.title}',),
                                    ),
                                  );
                                }
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _AudioArtView extends StatelessWidget {
  const _AudioArtView({required this.song});
  final Song song;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Hero(
          tag: song.id,
          child: AroraImage(
            imageUrl: song.thumbnailUrl,
            borderRadius: 20,
          ),
        ),
      ),
    );
  }
}

/// Inline video player using chewie (HLS muxed stream).
class _VideoView extends ConsumerStatefulWidget {
  const _VideoView({required this.songId});
  final String songId;

  @override
  ConsumerState<_VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends ConsumerState<_VideoView> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  StreamSubscription? _positionSub;
  StreamSubscription? _playingSub;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final useCase = GetVideoUrlUseCase(ref.read(musicProviderProvider));
      final song = ref.read(currentSongProvider).value;
      if (song == null) return;

      final url = await useCase(song);
      final ctrl = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await ctrl.initialize();

      // Phase 3 Option B: Video stream lacks audio, so we synchronize it with just_audio.
      final audioPlayer = ref.read(audioPlayerServiceProvider);

      // Initial sync
      await ctrl.seekTo(audioPlayer.position);
      if (audioPlayer.isPlaying) {
        await ctrl.play();
      }

      // Keep sync during playback
      _positionSub = audioPlayer.positionStream.listen((pos) {
        final vPos = ctrl.value.position;
        // If video drifts by more than 1 second, force resync.
        // This also handles user seeks natively via the app's bottom controls.
        if ((pos - vPos).inMilliseconds.abs() > 1000) {
          ctrl.seekTo(pos);
        }
      });

      _playingSub = audioPlayer.isPlayingStream.listen((playing) {
        if (playing && !ctrl.value.isPlaying) {
          ctrl.play();
        } else if (!playing && ctrl.value.isPlaying) {
          ctrl.pause();
        }
      });

      final chewie = ChewieController(
        videoPlayerController: ctrl,
        autoPlay: audioPlayer.isPlaying,
        showControls: false,
        looping: false,
        aspectRatio: ctrl.value.aspectRatio,
      );

      if (mounted) {
        setState(() {
          _videoController = ctrl;
          _chewieController = chewie;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '$e';
        });
      }
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playingSub?.cancel();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const AroraLoadingIndicator();
    if (_error != null) return const ErrorView(message: 'Video unavailable');
    return Chewie(controller: _chewieController!);
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab(
      {required this.label, required this.isSelected, required this.onTap,});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondaryDark,
              ),
        ),
      ),
    );
  }
}

class _DownloadButton extends ConsumerWidget {
  const _DownloadButton({required this.song});
  final Song song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadingIds = ref.watch(downloadingIdsProvider);
    final isDownloading = downloadingIds.contains(song.id);

    if (song.isDownloaded) {
      return const Icon(Icons.download_done_rounded, color: AppColors.success);
    }

    if (isDownloading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child:
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
      );
    }

    return IconButton(
      icon: const Icon(Icons.download_rounded),
      onPressed: () async {
        ref.read(downloadingIdsProvider.notifier).addId(song.id);
        await ref.read(downloadManagerProvider).download(song);
        ref.read(downloadingIdsProvider.notifier).removeId(song.id);
      },
    );
  }
}
