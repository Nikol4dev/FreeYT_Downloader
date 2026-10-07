import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import '../../core/app_info.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/labels.dart';
import '../engine/engine_service.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _updating = false;
  late final TextEditingController _dir = TextEditingController(text: ref.read(settingsProvider).downloadDir);
  late final TextEditingController _langs = TextEditingController(text: ref.read(settingsProvider).subLangs);

  @override
  void dispose() {
    _dir.dispose();
    _langs.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    setState(() => _updating = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final status = await ref.read(engineProvider).updateEngine();
      messenger.showSnackBar(SnackBar(content: Text(status == 'ALREADY_UP_TO_DATE' ? 'Up to date' : 'Updated')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Update failed: ${friendlyError(e)}')));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Widget _card(List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: cardDecoration(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  Widget _switch(String title, bool value, ValueChanged<bool> onChanged) => Material(
    type: MaterialType.transparency,
    child: SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      value: value,
      onChanged: onChanged,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    ref.listen(settingsProvider, (prev, next) {
      if (prev?.downloadDir != next.downloadDir && _dir.text != next.downloadDir) _dir.text = next.downloadDir;
    });

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        children: [
          Text('Settings', style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          _card([
            Text('Default quality', style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final q in qualityChoices)
                  ChoiceChip(
                    label: Text(chipLabel(q)),
                    selected: q == s.defaultQuality,
                    onSelected: (_) => notifier.change(s.copyWith(defaultQuality: q)),
                  ),
              ],
            ),
          ]),
          _card([
            Text('Downloads at once', style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (final n in [1, 2, 3, 4, 5]) ButtonSegment(value: n, label: Text('$n')),
              ],
              selected: {s.maxConcurrent},
              onSelectionChanged: (v) => notifier.change(s.copyWith(maxConcurrent: v.first)),
            ),
          ]),
          _card([
            Text('Folder', style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextField(
              controller: _dir,
              onChanged: (v) => notifier.change(ref.read(settingsProvider).copyWith(downloadDir: v.trim())),
              decoration: InputDecoration(
                hintText: Platform.isAndroid ? 'Subfolder name' : r'C:\Users\you\Videos\Downloader',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ]),
          _card([
            _switch('Remove sponsors', s.sponsorBlock, (v) => notifier.change(s.copyWith(sponsorBlock: v))),
            _switch('Subtitles', s.subtitles, (v) => notifier.change(s.copyWith(subtitles: v))),
            if (s.subtitles)
              TextField(
                controller: _langs,
                onChanged: (v) =>
                    notifier.change(ref.read(settingsProvider).copyWith(subLangs: v.trim().isEmpty ? 'en' : v.trim())),
                decoration: InputDecoration(
                  labelText: 'Languages',
                  hintText: 'en, de, es',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ]),
          _card([
            _switch('Download notifications', s.notifications, (v) => notifier.change(s.copyWith(notifications: v))),
            _switch(
              'Playback controls',
              s.playbackNotification,
              (v) => notifier.change(s.copyWith(playbackNotification: v)),
            ),
            _switch('Check for updates', s.checkUpdates, (v) => notifier.change(s.copyWith(checkUpdates: v))),
          ]),
          _card([
            _switch('Auto-fetch', s.autoFetch, (v) => notifier.change(s.copyWith(autoFetch: v))),
            _switch('Auto-update engine', s.autoUpdateEngine, (v) => notifier.change(s.copyWith(autoUpdateEngine: v))),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.blue,
                side: const BorderSide(color: Palette.blue, width: 1.5),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _updating ? null : _update,
              child: Text(_updating ? 'Updating' : 'Update engine'),
            ),
          ]),
          Center(
            child: Text('Version $appVersion', style: text.bodySmall?.copyWith(color: Palette.textSoft)),
          ),
        ],
      ),
    );
  }
}
