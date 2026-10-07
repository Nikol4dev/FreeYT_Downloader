import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/labels.dart';
import '../../download/application/download_queue_provider.dart';
import '../../engine/engine_service.dart';
import '../player_backend.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.media});

  final MediaEntity media;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final AppDatabase _db;
  final PlayerBackend _player = PlayerBackend();
  final FocusNode _focus = FocusNode();
  Timer? _hideTimer;
  Timer? _flashTimer;
  bool _controls = true;
  bool _fullscreen = false;
  bool _boost = false;
  bool _loop = false;
  double _rate = 1.0;
  double? _drag;
  double _tapX = 0;
  String? _flash;
  String? _error;

  static const _white = TextStyle(color: Colors.white, fontWeight: FontWeight.w600);

  @override
  void initState() {
    super.initState();
    _db = ref.read(databaseProvider);
    _open();
    _bump();
  }

  Future<void> _open() async {
    try {
      final uri = widget.media.contentUri;
      await _player.open(Platform.isAndroid ? uri : await ref.read(engineProvider).playable(uri));
      final resume = widget.media.lastPositionMs;
      if (resume > 2000) {
        if (_player.duration == Duration.zero) {
          await _player.changes
              .firstWhere((_) => _player.duration > Duration.zero)
              .timeout(const Duration(seconds: 10));
        }
        final d = _player.duration;
        if (resume < d.inMilliseconds - 3000) await _player.seek(Duration(milliseconds: resume));
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Cannot open file');
    }
  }

  @override
  void dispose() {
    _db.savePosition(widget.media.id, _player.position.inMilliseconds);
    _hideTimer?.cancel();
    _flashTimer?.cancel();
    _player.dispose();
    _focus.dispose();
    if (_fullscreen) _restoreSystemUi();
    super.dispose();
  }

  void _bump() {
    _hideTimer?.cancel();
    if (!_controls) setState(() => _controls = true);
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _player.playing && _drag == null) setState(() => _controls = false);
    });
  }

  void _toggleControls() {
    if (_controls) {
      _hideTimer?.cancel();
      setState(() => _controls = false);
    } else {
      _bump();
    }
  }

  void _showFlash(String text) {
    _flashTimer?.cancel();
    setState(() => _flash = text);
    _flashTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _flash = null);
    });
  }

  void _seekBy(int seconds) {
    final dur = _player.duration;
    var target = _player.position + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (dur > Duration.zero && target > dur) target = dur;
    _player.seek(target);
    _showFlash(seconds > 0 ? '+$seconds' : '$seconds');
  }

  void _togglePlay() {
    _player.playOrPause();
    _bump();
  }

  void _setRate(double v) {
    setState(() => _rate = double.parse(v.toStringAsFixed(2)));
    _player.setRate(_rate);
  }

  Future<void> _toggleFullscreen() async {
    setState(() => _fullscreen = !_fullscreen);
    if (Platform.isWindows) {
      await windowManager.setFullScreen(_fullscreen);
      return;
    }
    if (_fullscreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      _restoreSystemUi();
    }
  }

  void _restoreSystemUi() {
    if (Platform.isWindows) {
      windowManager.setFullScreen(false);
      return;
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([]);
  }

  Future<void> _openSettings() async {
    _hideTimer?.cancel();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.surface,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final subs = _player.subtitles;
          final current = _player.subtitle;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Speed  ${_rate.toStringAsFixed(2)}x', style: _white),
                  Slider(
                    min: 0.25,
                    max: 2,
                    divisions: 35,
                    value: _rate,
                    activeColor: Palette.blue,
                    onChanged: (v) {
                      _setRate(v);
                      setSheet(() {});
                    },
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final r in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
                        ChoiceChip(
                          label: Text('${r}x'),
                          selected: _rate == r,
                          onSelected: (_) {
                            _setRate(r);
                            setSheet(() {});
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Subtitles', style: _white),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Off'),
                        selected: current == 'no',
                        onSelected: (_) async {
                          await _player.setSubtitle('no');
                          setSheet(() {});
                        },
                      ),
                      for (final t in subs)
                        ChoiceChip(
                          label: Text(t.$2),
                          selected: current == t.$1,
                          onSelected: (_) async {
                            await _player.setSubtitle(t.$1);
                            setSheet(() {});
                          },
                        ),
                    ],
                  ),
                  if (subs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('None in this file', style: _white.copyWith(color: Colors.white54)),
                    ),
                  const SizedBox(height: 10),
                  Material(
                    type: MaterialType.transparency,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Loop', style: _white),
                      value: _loop,
                      onChanged: (v) {
                        setState(() => _loop = v);
                        _player.setLoop(v);
                        setSheet(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    _bump();
  }

  Widget _pill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(color: Colors.black.withAlpha(160), borderRadius: BorderRadius.circular(20)),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
    ),
  );

  Widget _overlay() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xAA000000), Color(0x00000000), Color(0x00000000), Color(0xCC000000)],
          stops: [0, 0.25, 0.65, 1],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(widget.media.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: _white),
              ),
              IconButton(color: Colors.white, icon: const Icon(Icons.settings), onPressed: _openSettings),
            ],
          ),
          const Spacer(),
          StreamBuilder<void>(
            stream: _player.changes,
            builder: (_, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 36,
                  color: Colors.white,
                  icon: const Icon(Icons.replay_10),
                  onPressed: () => _seekBy(-10),
                ),
                const SizedBox(width: 24),
                IconButton.filled(
                  iconSize: 44,
                  style: IconButton.styleFrom(backgroundColor: Palette.blue, foregroundColor: Colors.white),
                  icon: Icon(_player.playing ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlay,
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 36,
                  color: Colors.white,
                  icon: const Icon(Icons.forward_10),
                  onPressed: () => _seekBy(10),
                ),
              ],
            ),
          ),
          const Spacer(),
          StreamBuilder<void>(
            stream: _player.changes,
            builder: (context, _) {
              final total = _player.duration.inMilliseconds.toDouble();
              final max = total > 0 ? total : 1.0;
              final pos = (_drag ?? _player.position.inMilliseconds.toDouble()).clamp(0.0, max);
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 4, 8),
                child: Row(
                  children: [
                    Text(formatDuration(pos ~/ 1000), style: _white),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Palette.red,
                          thumbColor: Palette.red,
                          inactiveTrackColor: Colors.white24,
                          overlayColor: Palette.red.withAlpha(40),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          value: pos,
                          max: max,
                          onChangeStart: (_) => _hideTimer?.cancel(),
                          onChanged: (v) => setState(() => _drag = v),
                          onChangeEnd: (v) {
                            _player.seek(Duration(milliseconds: v.round()));
                            setState(() => _drag = null);
                            _bump();
                          },
                        ),
                      ),
                    ),
                    Text(formatDuration(total ~/ 1000), style: _white),
                    IconButton(
                      color: Colors.white,
                      icon: Icon(_fullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
                      onPressed: _toggleFullscreen,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.media;
    final stage = LayoutBuilder(
      builder: (context, box) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        onDoubleTapDown: (d) => _tapX = d.localPosition.dx,
        onDoubleTap: () => Platform.isWindows ? _toggleFullscreen() : _seekBy(_tapX < box.maxWidth / 2 ? -10 : 10),
        onLongPressStart: (_) {
          setState(() => _boost = true);
          _player.setRate(2);
        },
        onLongPressEnd: (_) {
          setState(() => _boost = false);
          _player.setRate(_rate);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (m.isAudioOnly && m.thumbnailUrl.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(m.thumbnailUrl, errorBuilder: (_, _, _) => const SizedBox()),
                  ),
                ),
              ),
            _player.view(),
            if (_flash != null) Center(child: _pill(_flash!)),
            if (_boost)
              Align(
                alignment: Alignment.topCenter,
                child: Padding(padding: const EdgeInsets.only(top: 56), child: _pill('2x')),
              ),
            AnimatedOpacity(
              opacity: _controls ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(ignoring: !_controls, child: _overlay()),
            ),
            if (_error != null) Center(child: Text(_error!, style: _white)),
          ],
        ),
      ),
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): _togglePlay,
        const SingleActivator(LogicalKeyboardKey.keyK): _togglePlay,
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _seekBy(-5),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _seekBy(5),
        const SingleActivator(LogicalKeyboardKey.keyJ): () => _seekBy(-10),
        const SingleActivator(LogicalKeyboardKey.keyL): () => _seekBy(10),
        const SingleActivator(LogicalKeyboardKey.keyM): _player.toggleMute,
        const SingleActivator(LogicalKeyboardKey.keyF): _toggleFullscreen,
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_fullscreen) {
            _toggleFullscreen();
          } else {
            Navigator.pop(context);
          }
        },
      },
      child: Focus(
        autofocus: true,
        focusNode: _focus,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(child: stage),
        ),
      ),
    );
  }
}
