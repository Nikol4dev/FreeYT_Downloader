import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/labels.dart';
import '../../../core/utils/youtube_url.dart';
import '../../../widgets/playlist_sheet.dart';
import '../../../widgets/pre_download_sheet.dart';
import '../../engine/engine_service.dart';
import '../../settings/settings_provider.dart';
import '../application/download_queue_provider.dart';
import 'download_task_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  bool _isInspecting = false;
  bool _isUpdating = false;
  String? _error;
  String? _clipboardLink;
  String? _lastOfferedLink;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(settingsProvider);
    unawaited(_checkClipboard());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_checkClipboard());
  }

  Future<void> _checkClipboard() async {
    final shared = await ref.read(engineProvider).takeSharedText();
    if (shared != null && shared.trim().isNotEmpty) {
      if (!mounted) return;
      final many = _videoLinks(shared);
      if (many.length > 1) {
        await _batch(many);
        return;
      }
      _controller.text = YoutubeUrl.findInText(shared) ?? shared.trim();
      _inspectUrl();
      return;
    }
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final link = data?.text == null ? null : YoutubeUrl.findInText(data!.text!);
    if (!mounted || link == null || (YoutubeUrl.extractId(link) == null && !YoutubeUrl.isPlaylist(link))) return;
    if (link == _lastOfferedLink || _controller.text.isNotEmpty) return;
    setState(() {
      _clipboardLink = link;
      _lastOfferedLink = link;
    });
  }

  List<String> _videoLinks(String text) =>
      YoutubeUrl.findAllInText(text).where((l) => YoutubeUrl.extractId(l) != null).toSet().toList();

  Future<void> _batch(List<String> links) async {
    final messenger = ScaffoldMessenger.of(context);
    final engine = ref.read(engineProvider);
    final queue = ref.read(downloadQueueProvider.notifier);
    if (await engine.isMetered()) {
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Mobile data'),
          content: Text('${links.length} videos'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Download')),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    setState(() => _isInspecting = true);
    var added = 0;
    for (final link in links) {
      try {
        final meta = await engine.fetchInfo(link);
        final quality = pickQuality(meta.qualityOptions, ref.read(settingsProvider).defaultQuality);
        if (await queue.enqueue(meta, quality) == EnqueueResult.added) added++;
      } catch (_) {}
    }
    if (mounted) setState(() => _isInspecting = false);
    messenger.showSnackBar(SnackBar(content: Text('Added $added of ${links.length}')));
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null) return;
    final many = _videoLinks(data!.text!);
    if (many.length > 1) {
      await _batch(many);
      return;
    }
    _controller.text = YoutubeUrl.findInText(data.text!) ?? data.text!.trim();
    setState(() => _error = null);
    if (ref.read(settingsProvider).autoFetch &&
        (YoutubeUrl.extractId(_controller.text) != null || YoutubeUrl.isPlaylist(_controller.text))) {
      _inspectUrl();
    }
  }

  Future<void> _inspectUrl() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty || _isInspecting) return;
    final playlist = YoutubeUrl.isPlaylist(raw);
    if (!playlist && YoutubeUrl.extractId(raw) == null) {
      setState(() => _error = 'Invalid link');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isInspecting = true;
      _error = null;
      _clipboardLink = null;
    });

    try {
      final engine = ref.read(engineProvider);
      if (playlist) {
        final info = await engine.fetchPlaylist(raw);
        if (!mounted) return;
        _controller.clear();
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => PlaylistSheet(info: info),
        );
      } else {
        final meta = await engine.fetchInfo(raw);
        if (!mounted) return;
        _controller.clear();
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => PreDownloadSheet(metadata: meta),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _isInspecting = false);
    }
  }

  Future<void> _updateEngine() async {
    setState(() => _isUpdating = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final status = await ref.read(engineProvider).updateEngine();
      messenger.showSnackBar(SnackBar(content: Text(status == 'ALREADY_UP_TO_DATE' ? 'Up to date' : 'Updated')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Update failed: ${friendlyError(e)}')));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(downloadQueueProvider);
    final hasFinished = tasks.any((t) => !t.isActive);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Palette.red,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Palette.red.withAlpha(130), blurRadius: 18, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: const Icon(Icons.south, color: Palette.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Downloader',
                      style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.05),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Update engine',
                    onPressed: _isUpdating ? null : _updateEngine,
                    icon: _isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Palette.text),
                          )
                        : const Icon(Icons.system_update_alt, color: Palette.text),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                decoration: fieldDecoration(),
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _inspectUrl(),
                  onChanged: (v) {
                    if (_error != null) setState(() => _error = null);
                    if (ref.read(settingsProvider).autoFetch &&
                        (YoutubeUrl.extractId(v.trim()) != null || YoutubeUrl.isPlaylist(v.trim()))) {
                      _inspectUrl();
                    }
                  },
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Paste link',
                    hintStyle: text.bodyLarge?.copyWith(color: Palette.textSoft),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(18, 18, 6, 18),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: TextButton(onPressed: _paste, child: const Text('Paste')),
                    ),
                  ),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 4),
                  child: Text(
                    _error!,
                    style: text.bodyMedium?.copyWith(color: Palette.red, fontWeight: FontWeight.w600),
                  ),
                ),
              if (_clipboardLink != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ActionChip(
                    avatar: const Icon(Icons.content_paste_go, size: 18, color: Palette.text),
                    label: const Text('Paste copied link'),
                    onPressed: () {
                      _controller.text = _clipboardLink!;
                      _inspectUrl();
                    },
                  ),
                ),
              const SizedBox(height: 16),
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
                onPressed: _isInspecting ? null : _inspectUrl,
                child: _isInspecting
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Palette.white),
                          ),
                          SizedBox(width: 12),
                          Text('Fetching'),
                        ],
                      )
                    : const Text('Fetch'),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Text('Queue', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  if (hasFinished)
                    TextButton(
                      onPressed: ref.read(downloadQueueProvider.notifier).clearFinished,
                      child: const Text('Clear finished'),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: tasks.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.download_for_offline_outlined, size: 48, color: Palette.textSoft),
                              const SizedBox(height: 8),
                              Text('Paste or share a link', style: text.bodyMedium?.copyWith(color: Palette.textSoft)),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: tasks.length,
                        itemBuilder: (_, i) => DownloadTaskTile(key: ValueKey(tasks[i].id), task: tasks[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
