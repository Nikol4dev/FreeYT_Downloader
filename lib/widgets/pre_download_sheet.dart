import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/labels.dart';
import '../features/download/application/download_queue_provider.dart';
import '../features/engine/engine_service.dart';
import '../features/player/player_backend.dart';
import '../features/settings/settings_provider.dart';
import '../models/video_metadata.dart';

class PreDownloadSheet extends ConsumerStatefulWidget {
  const PreDownloadSheet({super.key, required this.metadata});

  final VideoMetadata metadata;

  @override
  ConsumerState<PreDownloadSheet> createState() => _PreDownloadSheetState();
}

class _PreDownloadSheetState extends ConsumerState<PreDownloadSheet> {
  late String _quality;
  late RangeValues _range;
  bool _busy = false;
  bool _clip = false;
  bool _exact = false;
  PlayerBackend? _player;
  StreamSubscription<void>? _watch;
  bool _loading = false;
  bool _playClip = false;
  String? _previewError;

  int get _length => widget.metadata.durationSeconds;

  @override
  void initState() {
    super.initState();
    _quality = pickQuality(widget.metadata.qualityOptions, ref.read(settingsProvider).defaultQuality);
    _range = RangeValues(0, _length > 0 ? _length.toDouble() : 1);
  }

  @override
  void dispose() {
    _watch?.cancel();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _startPreview() async {
    if (_player != null || _loading) return;
    setState(() {
      _loading = true;
      _previewError = null;
    });
    try {
      final url = await ref.read(engineProvider).previewUrl(widget.metadata.url);
      if (!mounted) return;
      final player = PlayerBackend();
      await player.open(url);
      _watch = player.changes.listen((_) {
        if (_playClip && player.position.inMilliseconds >= _range.end * 1000) {
          _playClip = false;
          if (player.playing) player.playOrPause();
        }
      });
      if (!mounted) {
        await player.dispose();
        return;
      }
      setState(() {
        _player = player;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _previewError = friendlyError(e);
        });
      }
    }
  }

  void _toggleClip(bool on) {
    setState(() => _clip = on);
    if (on) {
      _startPreview();
    } else if (_player?.playing == true) {
      _player!.playOrPause();
    }
  }

  void _setEdge(bool start, Duration pos) {
    final s = pos.inMilliseconds / 1000.0;
    setState(() {
      if (start) {
        _range = RangeValues(s.clamp(0.0, _range.end - 1).floorToDouble(), _range.end);
      } else {
        _range = RangeValues(
          _range.start,
          min(s.clamp(_range.start + 1, _length.toDouble()).ceilToDouble(), _length.toDouble()),
        );
      }
    });
  }

  Future<void> _previewSelection() async {
    final p = _player;
    if (p == null) return;
    await p.seek(Duration(seconds: _range.start.round()));
    _playClip = true;
    if (!p.playing) await p.playOrPause();
  }

  void _nudge(bool start, int delta) {
    setState(() {
      if (start) {
        _range = RangeValues((_range.start + delta).clamp(0, _range.end - 1).toDouble(), _range.end);
      } else {
        _range = RangeValues(_range.start, (_range.end + delta).clamp(_range.start + 1, _length.toDouble()).toDouble());
      }
    });
    _player?.seek(Duration(seconds: (start ? _range.start : _range.end).round()));
  }

  int _estimate(String q) {
    final size = widget.metadata.sizeFor(q);
    if (!_clip || _length == 0) return size;
    return (size * (_range.end - _range.start) / _length).round();
  }

  String _label(String q) {
    final size = _estimate(q);
    return size > 0 ? '${chipLabel(q)} · ${formatSize(size)}' : chipLabel(q);
  }

  Future<bool> _confirmMetered() async {
    if (!await ref.read(engineProvider).isMetered()) return true;
    if (!mounted) return false;
    final size = _estimate(_quality);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mobile data'),
        content: Text(size > 0 ? 'About ${formatSize(size)}' : 'Size unknown'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Download')),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _enqueue() async {
    if (!await _confirmMetered()) return;
    if (!mounted) return;
    setState(() => _busy = true);
    if (_player?.playing == true) _player!.playOrPause();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final result = await ref
        .read(downloadQueueProvider.notifier)
        .enqueue(
          widget.metadata,
          _quality,
          clipStart: _clip ? _range.start.round() : null,
          clipEnd: _clip ? _range.end.round() : null,
          exactCut: _exact,
        );
    nav.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          EnqueueResult.added => 'Added',
          EnqueueResult.alreadyQueued => 'Already queued',
          EnqueueResult.alreadyInLibrary => 'Already saved',
        }),
      ),
    );
  }

  Widget _time(String label, bool start) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.remove),
        onPressed: () => _nudge(start, -1),
      ),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.add), onPressed: () => _nudge(start, 1)),
    ],
  );

  Widget _media(VideoMetadata meta) {
    Widget content;
    if (_clip && _player != null) {
      content = _player!.view();
    } else if (_clip && _previewError != null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_previewError!, textAlign: TextAlign.center),
            ),
            TextButton(
              onPressed: () {
                setState(() => _previewError = null);
                _startPreview();
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    } else if (_clip) {
      content = const Center(child: CircularProgressIndicator());
    } else {
      content = meta.thumbnailUrl.isEmpty
          ? const SizedBox()
          : Image.network(
              meta.thumbnailUrl,
              fit: BoxFit.cover,
              cacheWidth: 900,
              errorBuilder: (_, _, _) => const SizedBox(),
            );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_clip ? Palette.red : Palette.blue).withAlpha(70),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ColoredBox(color: Colors.black, child: content),
        ),
      ),
    );
  }

  Widget _previewControls() {
    final p = _player;
    return StreamBuilder<void>(
      stream: p?.changes,
      builder: (_, _) {
        final pos = p?.position ?? Duration.zero;
        final max = _length > 0 ? _length.toDouble() : 1.0;
        return Column(
          children: [
            Row(
              children: [
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: Palette.blue, foregroundColor: Palette.white),
                  icon: Icon(p?.playing == true ? Icons.pause : Icons.play_arrow),
                  onPressed: p == null
                      ? null
                      : () {
                          _playClip = false;
                          p.playOrPause();
                        },
                ),
                const SizedBox(width: 8),
                Text(formatDuration(pos.inSeconds), style: const TextStyle(fontWeight: FontWeight.w700)),
                Expanded(
                  child: Slider(
                    value: (pos.inMilliseconds / 1000).clamp(0.0, max),
                    max: max,
                    onChanged: p == null ? null : (v) => p.seek(Duration(milliseconds: (v * 1000).round())),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.first_page),
                    label: const Text('Start here'),
                    onPressed: p == null ? null : () => _setEdge(true, pos),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.last_page),
                    label: const Text('End here'),
                    onPressed: p == null ? null : () => _setEdge(false, pos),
                  ),
                ),
                IconButton(
                  tooltip: 'Play clip',
                  color: Palette.red,
                  icon: const Icon(Icons.slideshow),
                  onPressed: p == null ? null : _previewSelection,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.metadata;
    final text = Theme.of(context).textTheme;

    return SingleChildScrollView(
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
          _media(meta),
          const SizedBox(height: 14),
          Text(
            meta.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            [if (meta.channel.isNotEmpty) meta.channel, if (_length > 0) formatDuration(_length)].join(' · '),
            style: text.bodyMedium?.copyWith(color: Palette.textSoft),
          ),
          const SizedBox(height: 20),
          Text('Quality', style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final q in meta.qualityOptions)
                ChoiceChip(
                  label: Text(_label(q)),
                  selected: q == _quality,
                  onSelected: _busy ? null : (_) => setState(() => _quality = q),
                ),
            ],
          ),
          if (_length > 1) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Clip', style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
              value: _clip,
              onChanged: _busy ? null : _toggleClip,
            ),
            if (_clip) ...[
              _previewControls(),
              const SizedBox(height: 4),
              RangeSlider(
                values: _range,
                min: 0,
                max: _length.toDouble(),
                divisions: _length,
                activeColor: Palette.red,
                labels: RangeLabels(formatDuration(_range.start.round()), formatDuration(_range.end.round())),
                onChanged: (v) {
                  final startMoved = v.start != _range.start;
                  setState(() => _range = v);
                  _player?.seek(Duration(seconds: (startMoved ? v.start : v.end).round()));
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _time(formatDuration(_range.start.round()), true),
                  Text(
                    formatDuration((_range.end - _range.start).round()),
                    style: const TextStyle(color: Palette.red, fontWeight: FontWeight.w900),
                  ),
                  _time(formatDuration(_range.end.round()), false),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Exact cuts'),
                subtitle: const Text('Slower'),
                value: _exact,
                onChanged: (v) => setState(() => _exact = v),
              ),
            ],
          ],
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              elevation: 8,
              shadowColor: (_clip ? Palette.red : Palette.blue).withAlpha(200),
              backgroundColor: _clip ? Palette.red : Palette.blue,
              foregroundColor: Palette.white,
              disabledBackgroundColor: Palette.blue.withAlpha(120),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            onPressed: _busy ? null : _enqueue,
            child: Text(_clip ? 'Download clip' : 'Download'),
          ),
        ],
      ),
    );
  }
}
