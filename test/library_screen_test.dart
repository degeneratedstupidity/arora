import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arora/domain/entities/playlist.dart';
import 'package:arora/domain/entities/song.dart';
import 'package:arora/features/library/screens/library_screen.dart';
import 'package:arora/features/library/providers/library_providers.dart';
import 'package:arora/core/theme/theme_provider.dart';

void main() {
  testWidgets('LibraryScreen open playlist bottom sheet', (WidgetTester tester) async {
    final playlist = Playlist(
      id: 'p1',
      title: 'My Playlist',
      songs: [
        Song(id: 's1', title: 'Song 1', artistName: 'Artist', thumbnailUrl: '', durationMs: 100)
      ],
    );
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playlistsProvider.overrideWith((ref) => Future.value([playlist])),
        ],
        child: MaterialApp(
          home: const LibraryScreen(),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    expect(find.text('My Playlist'), findsOneWidget);
    
    // Tap the playlist
    await tester.tap(find.text('My Playlist'));
    
    // Try to pump the bottom sheet
    await tester.pumpAndSettle();
    
    // If it threw an exception, it will fail the test.
    expect(find.text('Song 1'), findsOneWidget);
  });
}
