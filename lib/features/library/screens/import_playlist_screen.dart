import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arora/core/theme/app_colors.dart';
import 'package:arora/services/playlist_import_service.dart';
import 'package:arora/shared/widgets/arora_image.dart';
import 'package:arora/shared/widgets/loading_indicator.dart';

class ImportPlaylistScreen extends ConsumerStatefulWidget {
  const ImportPlaylistScreen({super.key});

  @override
  ConsumerState<ImportPlaylistScreen> createState() =>
      _ImportPlaylistScreenState();
}

class _ImportPlaylistScreenState extends ConsumerState<ImportPlaylistScreen> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(playlistImportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Playlist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste a YouTube Music playlist link:'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: 'https://music.youtube.com/playlist?list=...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(64, 40),
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    ref
                        .read(playlistImportProvider.notifier)
                        .importFromUrl(_urlController.text);
                  },
                  child: const Text('Import'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: importState.when(
                data: (songs) {
                  if (songs.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            return ListTile(
                              leading: AroraImage(
                                imageUrl: song.thumbnailUrl,
                                width: 48,
                                height: 48,
                                borderRadius: 8,
                              ),
                              title: Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                song.artistName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            ref
                                .read(playlistImportProvider.notifier)
                                .saveToLibrary(songs);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Saved ${songs.length} songs to Library!',
                                ),
                              ),
                            );
                            if (context.canPop()) context.pop();
                          },
                          icon: const Icon(Icons.save_alt_rounded),
                          label: Text('Save ${songs.length} Songs to Library'),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const AroraLoadingIndicator(),
                error: (err, _) => Center(
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
