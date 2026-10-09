import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/add_to_playlist.dart';
import '../../../widgets/backdrop.dart';
import '../../../widgets/media_tile.dart';
import '../../download/application/download_queue_provider.dart';
import '../open_media.dart';
import 'library_screen.dart';

final playlistMediaProvider = StreamProvider.family<List<MediaEntity>, int>(
  (ref, id) => ref.watch(databaseProvider).watchPlaylistMedia(id),
);

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key, required this.playlist});

  final PlaylistRow playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final items = ref.watch(playlistMediaProvider(playlist.id));
    final name =
        ref.watch(playlistsProvider).asData?.value.where((p) => p.id == playlist.id).firstOrNull?.name ?? playlist.name;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Palette.text,
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (k) async {
              if (k == 'Rename') {
                final value = await askName(context, title: 'Rename', initial: name);
                if (value != null && value.isNotEmpty) await db.renamePlaylist(playlist.id, value);
              } else {
                await db.deletePlaylist(playlist.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Rename', child: Text('Rename')),
              PopupMenuItem(value: 'Delete playlist', child: Text('Delete playlist')),
            ],
          ),
        ],
      ),
      body: Backdrop(
        child: items.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (list) => list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(22),
                  child: Text('Empty', style: TextStyle(color: Palette.textSoft)),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(22, 8, 22, 24 + MediaQuery.viewPaddingOf(context).bottom),
                  itemCount: list.length + 1,
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Play'),
                                onPressed: () => openMedia(context, ref, list, 0),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.shuffle),
                                label: const Text('Shuffle'),
                                onPressed: () =>
                                    openMedia(context, ref, list, Random().nextInt(list.length), shuffle: true),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final i = index - 1;
                    final m = list[i];
                    return MediaTile(
                      media: m,
                      onOpen: () => openMedia(context, ref, list, i),
                      onFavorite: () => db.setFavorite(m.id, !m.isFavorite),
                      menu: {'Remove from playlist': () => db.removeFromPlaylist(playlist.id, m.id)},
                    );
                  },
                ),
        ),
      ),
    );
  }
}
