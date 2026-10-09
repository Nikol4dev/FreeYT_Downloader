import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/labels.dart';
import '../features/download/application/download_queue_provider.dart';
import '../features/engine/engine_service.dart';
import '../features/settings/settings_provider.dart';
import '../models/video_metadata.dart';

class PlaylistSheet extends ConsumerStatefulWidget {
  const PlaylistSheet({super.key, required this.info});

  final PlaylistInfo info;

  @override
  ConsumerState<PlaylistSheet> createState() => _PlaylistSheetState();
}

class _PlaylistSheetState extends ConsumerState<PlaylistSheet> {
  late final Set<String> _selected = {for (final e in widget.info.entries) e.id};
  late String _quality = qualityChoices.contains(ref.read(settingsProvider).defaultQuality)
      ? ref.read(settingsProvider).defaultQuality
      : 'Best';
  bool _asPlaylist = true;
  bool _busy = false;

  Future<void> _download() async {
    if (await ref.read(engineProvider).isMetered()) {
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Palette.surface,
          title: const Text('Mobile data'),
          content: Text('${_selected.length} videos'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Download')),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final items = widget.info.entries.where((e) => _selected.contains(e.id)).toList();
    final added = await ref
        .read(downloadQueueProvider.notifier)
        .enqueueAll(items, _quality, _asPlaylist ? widget.info.title : null);
    nav.pop();
    messenger.showSnackBar(SnackBar(content: Text('Added $added')));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final entries = widget.info.entries;
    final all = _selected.length == entries.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        4,
        22,
        MediaQuery.of(context).viewInsets.bottom + MediaQuery.viewPaddingOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.info.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          Row(
            children: [
              Text('${entries.length} videos', style: text.bodyMedium?.copyWith(color: Palette.textSoft)),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  if (all) {
                    _selected.clear();
                  } else {
                    _selected.addAll(entries.map((e) => e.id));
                  }
                }),
                child: Text(all ? 'None' : 'All'),
              ),
            ],
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.38),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final e = entries[i];
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _selected.contains(e.id),
                  onChanged: (v) => setState(() => v == true ? _selected.add(e.id) : _selected.remove(e.id)),
                  title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: e.durationSeconds > 0 ? Text(formatDuration(e.durationSeconds)) : null,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final q in qualityChoices)
                ChoiceChip(
                  label: Text(chipLabel(q)),
                  selected: q == _quality,
                  onSelected: _busy ? null : (_) => setState(() => _quality = q),
                ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Save as playlist'),
            value: _asPlaylist,
            onChanged: (v) => setState(() => _asPlaylist = v),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              elevation: 8,
              shadowColor: Palette.blue.withAlpha(200),
              backgroundColor: Palette.blue,
              foregroundColor: Palette.white,
              disabledBackgroundColor: Palette.blue.withAlpha(120),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            onPressed: _busy || _selected.isEmpty ? null : _download,
            child: Text('Download ${_selected.length}'),
          ),
        ],
      ),
    );
  }
}
