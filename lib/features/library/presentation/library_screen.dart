import 'dart:io' show Platform;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/labels.dart';
import '../../../widgets/add_to_playlist.dart';
import '../../../widgets/media_tile.dart';
import '../../download/application/download_queue_provider.dart';
import '../../engine/engine_service.dart';
import '../open_media.dart';
import '../../settings/settings_provider.dart';
import 'playlist_screen.dart';

typedef LibraryArgs = (String, LibrarySort, bool);

final libraryProvider = StreamProvider.family<List<MediaEntity>, LibraryArgs>(
  (ref, a) => ref.watch(databaseProvider).watchLibrary(query: a.$1, sort: a.$2, favoritesOnly: a.$3),
);

final playlistsProvider = StreamProvider<List<PlaylistRow>>((ref) => ref.watch(databaseProvider).watchPlaylistRows());

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _query = '';
  LibrarySort _sort = LibrarySort.recent;
  bool _favorites = false;
  int _tab = 0;
  final Set<int> _picked = {};
  List<MediaEntity> _shown = const [];

  void _toggle(int id) => setState(() => _picked.contains(id) ? _picked.remove(id) : _picked.add(id));

  Future<void> _deletePicked() async {
    final items = _shown.where((m) => _picked.contains(m.id)).toList();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${items.length}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Palette.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    for (final m in items) {
      await ref.read(engineProvider).delete(m.contentUri);
      await ref.read(databaseProvider).deleteMedia(m.id);
    }
    setState(() => _picked.clear());
  }

  Widget _selectionBar() => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: Palette.blue.withAlpha(36),
      borderRadius: BorderRadius.circular(18),
      border: const Border.fromBorderSide(BorderSide(color: Palette.blue)),
    ),
    child: Row(
      children: [
        IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _picked.clear())),
        Text('${_picked.length}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const Spacer(),
        IconButton(
          tooltip: 'Add to playlist',
          icon: const Icon(Icons.playlist_add),
          onPressed: () => addToPlaylist(context, ref, _shown.where((m) => _picked.contains(m.id)).toList()),
        ),
        IconButton(
          tooltip: 'Delete',
          color: Palette.red,
          icon: const Icon(Icons.delete_outline),
          onPressed: _deletePicked,
        ),
      ],
    ),
  );

  Future<void> _import() async {
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseProvider);
    try {
      final items = await ref.read(engineProvider).scanFolder(ref.read(settingsProvider).downloadDir);
      final known = (await db.select(db.mediaFiles).get()).map((m) => m.contentUri).toSet();
      var added = 0;
      for (final i in items) {
        final uri = i['uri'] as String;
        if (known.contains(uri)) continue;
        final name = i['name'] as String;
        await db.upsertMedia(
          MediaFilesCompanion.insert(
            youtubeId: 'local:$uri',
            title: name.contains('.') ? name.substring(0, name.lastIndexOf('.')) : name,
            contentUri: uri,
            durationMs: (i['durationMs'] as num?)?.toInt() ?? 0,
            thumbnailUrl: '',
            fileSizeBytes: Value((i['sizeBytes'] as num?)?.toInt() ?? 0),
            isAudioOnly: Value(i['audio'] == true),
          ),
        );
        added++;
      }
      messenger.showSnackBar(SnackBar(content: Text('Imported $added')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  String _sortLabel(LibrarySort s) => switch (s) {
    LibrarySort.recent => 'Recent',
    LibrarySort.title => 'Title',
    LibrarySort.channel => 'Channel',
    LibrarySort.size => 'Size',
  };

  Future<bool> _confirmDelete(MediaEntity m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Palette.surface,
        title: const Text('Delete?'),
        content: Text(m.title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Palette.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return false;
    await ref.read(engineProvider).delete(m.contentUri);
    await ref.read(databaseProvider).deleteMedia(m.id);
    return true;
  }

  List<MediaEntity> _resume(List<MediaEntity> data) => _query.isEmpty && !_favorites
      ? data
            .where((m) => m.lastPositionMs > 3000 && m.durationMs > 0 && m.lastPositionMs < m.durationMs - 5000)
            .take(10)
            .toList()
      : const [];

  Widget _continueRow(List<MediaEntity> items, TextTheme text) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Continue', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final m = items[i];
              final f = (m.lastPositionMs / m.durationMs).clamp(0.0, 1.0);
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => openMedia(context, ref, m),
                child: SizedBox(
                  width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 160,
                          height: 90,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              m.thumbnailUrl.isEmpty
                                  ? const ColoredBox(color: Palette.surface2)
                                  : Image.network(
                                      m.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      cacheWidth: 480,
                                      errorBuilder: (_, _, _) => const ColoredBox(color: Palette.surface2),
                                    ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: FractionallySizedBox(
                                  widthFactor: f,
                                  child: Container(height: 4, color: Palette.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        m.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );

  Future<void> _newPlaylist() async {
    final name = await askName(context, title: 'New playlist');
    if (name != null && name.isNotEmpty) await ref.read(databaseProvider).createPlaylist(name);
  }

  Widget _all(TextTheme text) {
    final items = ref.watch(libraryProvider((_query, _sort, _favorites)));
    final list = items.asData?.value ?? const <MediaEntity>[];
    final total = list.fold<int>(0, (sum, m) => sum + m.fileSizeBytes);
    _shown = list;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_picked.isNotEmpty)
          _selectionBar()
        else
          Container(
            decoration: fieldDecoration(),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: text.bodyLarge?.copyWith(color: Palette.textSoft),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Palette.text),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            PopupMenuButton<LibrarySort>(
              onSelected: (v) => setState(() => _sort = v),
              itemBuilder: (_) => [
                for (final s in LibrarySort.values) PopupMenuItem(value: s, child: Text(_sortLabel(s))),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sort, size: 20),
                    const SizedBox(width: 4),
                    Text(_sortLabel(_sort), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Favorites'),
              selected: _favorites,
              onSelected: (v) => setState(() => _favorites = v),
            ),
            const Spacer(),
            Text(
              '${list.length} · ${formatSize(total)}',
              style: text.bodySmall?.copyWith(color: Palette.textSoft, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: items.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Palette.red)),
            data: (data) => data.isEmpty
                ? Text(
                    _query.isEmpty && !_favorites ? 'Empty' : 'No results',
                    style: text.bodyMedium?.copyWith(color: Palette.textSoft),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: data.length + (_resume(data).isEmpty ? 0 : 1),
                    itemBuilder: (_, i) {
                      final resume = _resume(data);
                      if (resume.isNotEmpty && i == 0) return _continueRow(resume, text);
                      final m = data[i - (resume.isEmpty ? 0 : 1)];
                      return Dismissible(
                        key: ValueKey(m.id),
                        direction: _picked.isEmpty ? DismissDirection.endToStart : DismissDirection.none,
                        confirmDismiss: (_) => _confirmDelete(m),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: const BoxDecoration(color: Palette.red, borderRadius: cardRadius),
                          child: const Icon(Icons.delete_outline, color: Palette.white),
                        ),
                        child: MediaTile(
                          media: m,
                          onOpen: () => _picked.isEmpty ? openMedia(context, ref, m) : _toggle(m.id),
                          onLongPress: () => _toggle(m.id),
                          selected: _picked.contains(m.id),
                          onFavorite: () => ref.read(databaseProvider).setFavorite(m.id, !m.isFavorite),
                          menu: {
                            'Add to playlist': () => addToPlaylist(context, ref, [m]),
                            if (!Platform.isAndroid)
                              'Show in folder': () => ref.read(engineProvider).open(m.contentUri),
                            'Delete': () => _confirmDelete(m),
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _playlists(TextTheme text) {
    final lists = ref.watch(playlistsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(onPressed: _newPlaylist, icon: const Icon(Icons.add), label: const Text('New playlist')),
        const SizedBox(height: 8),
        Expanded(
          child: lists.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Palette.red)),
            data: (data) => data.isEmpty
                ? Text('Empty', style: text.bodyMedium?.copyWith(color: Palette.textSoft))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: data.length,
                    itemBuilder: (_, i) {
                      final l = data[i];
                      return InkWell(
                        borderRadius: cardRadius,
                        onTap: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (_) => PlaylistScreen(playlist: l))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: cardDecoration(),
                          child: Row(
                            children: [
                              const Icon(Icons.queue_music, color: Palette.blue),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  l.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ),
                              Text('${l.count}', style: text.bodyMedium?.copyWith(color: Palette.textSoft)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Library', style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                ),
                IconButton(
                  tooltip: 'Import files',
                  icon: const Icon(Icons.drive_folder_upload_outlined),
                  onPressed: _import,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 0, label: Text('All')),
                ButtonSegment(value: 1, label: Text('Playlists')),
              ],
              selected: {_tab},
              onSelectionChanged: (v) => setState(() => _tab = v.first),
            ),
            const SizedBox(height: 16),
            Expanded(child: _tab == 0 ? _all(text) : _playlists(text)),
          ],
        ),
      ),
    );
  }
}
