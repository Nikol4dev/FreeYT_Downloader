import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/app_database.dart';
import '../core/theme/app_theme.dart';
import '../features/download/application/download_queue_provider.dart';

Future<String?> askName(BuildContext context, {String title = 'Name', String initial = ''}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Palette.surface,
      title: Text(title),
      content: TextField(controller: controller, autofocus: true, onSubmitted: (v) => Navigator.pop(ctx, v.trim())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('OK')),
      ],
    ),
  );
}

Future<void> addToPlaylist(BuildContext context, WidgetRef ref, List<MediaEntity> items) async {
  final db = ref.read(databaseProvider);
  final messenger = ScaffoldMessenger.of(context);
  final lists = await db.watchPlaylistRows().first;
  if (!context.mounted) return;
  final choice = await showModalBottomSheet<int>(
    context: context,
    builder: (ctx) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New playlist'),
            onTap: () => Navigator.pop(ctx, -1),
          ),
          for (final l in lists)
            ListTile(
              leading: const Icon(Icons.queue_music),
              title: Text(l.name),
              trailing: Text('${l.count}'),
              onTap: () => Navigator.pop(ctx, l.id),
            ),
        ],
      ),
    ),
  );
  if (choice == null) return;
  var id = choice;
  if (id == -1) {
    if (!context.mounted) return;
    final name = await askName(context, title: 'New playlist');
    if (name == null || name.isEmpty) return;
    id = await db.createPlaylist(name);
  }
  for (final m in items) {
    await db.addToPlaylist(id, m.id);
  }
  messenger.showSnackBar(const SnackBar(content: Text('Added')));
}
