import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/labels.dart';
import '../playback_controller.dart';
import '../player_backend.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  final FocusNode _focus = FocusNode();
  Timer? _hideTimer;
  Timer? _flashTimer;
  bool _controls = true;
  bool _fullscreen = false;
  bool _boost = false;
  double? _drag;
  double _tapX = 0;
  String? _flash;

  static const _white = TextStyle(color: Colors.white, fontWeight: FontWeight.w600);

  PlaybackController get _ctl => ref.read(playbackProvider.notifier);
  PlayerBackend? get _player => ref.read(playbackProvider).player;

  @override
  void initState() {
    super.initState();
    _bump();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _flashTimer?.cancel();
    _focus.dispose();
    if (_fullscreen) _restoreSystemUi();
    super.dispose();
  }

  void _bump() {
    _hideTimer?.cancel();
    if (!_controls) setState(() => _controls = true);
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && (_player?.playing ?? false) && _drag == null) setState(() => _controls = false);
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
    final p = _player;
    if (p == null) return;
    var target = p.position + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (p.duration > Duration.zero && target > p.duration) target = p.duration;
    p.seek(target);
    _showFlash(seconds > 0 ? '+$seconds' : '$seconds');
  }

  void _togglePlay() {
    _player?.playOrPause();
    _bump();
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
      isScrollControlled: true,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final s = ref.watch(playbackProvider);
          final p = s.player;
          final subs = p?.subtitles ?? const [];
          final current = p?.subtitle ?? 'no';
          final sleepLeft = s.sleepAt?.difference(DateTime.now());
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Speed  ${s.rate.toStringAsFixed(2)}x', style: _white),
                  Slider(
                    min: 0.25,
                    max: 2,
                    divisions: 35,
                    value: s.rate,
                    onChanged: (v) => _ctl.setRate(double.parse(v.toStringAsFixed(2))),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final r in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
                        ChoiceChip(label: Text('${r}x'), selected: s.rate == r, onSelected: (_) => _ctl.setRate(r)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Repeat', style: _white),
                  const SizedBox(height: 8),
                  SegmentedButton<LoopMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: LoopMode.off, label: Text('Off')),
                      ButtonSegment(value: LoopMode.all, label: Text('All')),
                      ButtonSegment(value: LoopMode.one, label: Text('One')),
                    ],
                    selected: {s.repeat},
                    onSelectionChanged: (v) => _ctl.setRepeat(v.first),
                  ),
                  Material(
                    type: MaterialType.transparency,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Shuffle', style: _white),
                      value: s.shuffle,
                      onChanged: (_) => _ctl.toggleShuffle(),
                    ),
                  ),
                  Text(
                    s.sleepAtEnd
                        ? 'Sleep timer  end of video'
                        : sleepLeft != null
                        ? 'Sleep timer  ${formatDuration(sleepLeft.inSeconds)} left'
                        : 'Sleep timer',
                    style: _white,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Off'),
                        selected: s.sleepAt == null && !s.sleepAtEnd,
                        onSelected: (_) => _ctl.setSleep(null),
                      ),
                      for (final m in [15, 30, 60])
                        ChoiceChip(
                          label: Text('$m min'),
                          selected: false,
                          onSelected: (_) => _ctl.setSleep(Duration(minutes: m)),
                        ),
                      ChoiceChip(
                        label: const Text('End of video'),
                        selected: s.sleepAtEnd,
                        onSelected: (_) => _ctl.setSleep(null, endOfVideo: true),
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
                        onSelected: (_) => p?.setSubtitle('no'),
                      ),
                      for (final t in subs)
                        ChoiceChip(
                          label: Text(t.$2),
                          selected: current == t.$1,
                          onSelected: (_) => p?.setSubtitle(t.$1),
                        ),
                    ],
                  ),
                  if (subs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('None in this file', style: _white.copyWith(color: Colors.white54)),
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

  Widget _overlay(PlaybackInfo s, PlayerBackend p) {
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
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(s.current?.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: _white),
              ),
              IconButton(color: Colors.white, icon: const Icon(Icons.settings), onPressed: _openSettings),
            ],
          ),
          const Spacer(),
          StreamBuilder<void>(
            stream: p.changes,
            builder: (_, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 30,
                  color: Colors.white,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _ctl.previous,
                ),
                IconButton(
                  iconSize: 32,
                  color: Colors.white,
                  icon: const Icon(Icons.replay_10),
                  onPressed: () => _seekBy(-10),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  iconSize: 44,
                  style: IconButton.styleFrom(backgroundColor: Palette.blue, foregroundColor: Colors.white),
                  icon: Icon(p.playing ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlay,
                ),
                const SizedBox(width: 12),
                IconButton(
                  iconSize: 32,
                  color: Colors.white,
                  icon: const Icon(Icons.forward_10),
                  onPressed: () => _seekBy(10),
                ),
                IconButton(
                  iconSize: 30,
                  color: Colors.white,
                  icon: const Icon(Icons.skip_next),
                  onPressed: s.hasNext ? () => _ctl.next() : null,
                ),
              ],
            ),
          ),
          const Spacer(),
          StreamBuilder<void>(
            stream: p.changes,
            builder: (context, _) {
              final total = p.duration.inMilliseconds.toDouble();
              final max = total > 0 ? total : 1.0;
              final pos = (_drag ?? p.position.inMilliseconds.toDouble()).clamp(0.0, max);
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
                            p.seek(Duration(milliseconds: v.round()));
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
    final s = ref.watch(playbackProvider);
    final p = s.player;
    final m = s.current;

    if (p == null || m == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stage = LayoutBuilder(
      builder: (context, box) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        onDoubleTapDown: (d) => _tapX = d.localPosition.dx,
        onDoubleTap: () => Platform.isWindows ? _toggleFullscreen() : _seekBy(_tapX < box.maxWidth / 2 ? -10 : 10),
        onLongPressStart: (_) {
          setState(() => _boost = true);
          p.setRate(2);
        },
        onLongPressEnd: (_) {
          setState(() => _boost = false);
          p.setRate(s.rate);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (m.isAudioOnly && m.thumbnailUrl.startsWith('http'))
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(m.thumbnailUrl, errorBuilder: (_, _, _) => const SizedBox()),
                  ),
                ),
              ),
            KeyedSubtree(key: ValueKey(p), child: p.view()),
            if (_flash != null) Center(child: _pill(_flash!)),
            if (_boost)
              Align(
                alignment: Alignment.topCenter,
                child: Padding(padding: const EdgeInsets.only(top: 56), child: _pill('2x')),
              ),
            AnimatedOpacity(
              opacity: _controls ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(ignoring: !_controls, child: _overlay(s, p)),
            ),
            if (s.error != null) Center(child: Text(s.error!, style: _white)),
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
        const SingleActivator(LogicalKeyboardKey.keyN): () => _ctl.next(),
        const SingleActivator(LogicalKeyboardKey.keyP): _ctl.previous,
        const SingleActivator(LogicalKeyboardKey.keyM): () => _player?.toggleMute(),
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
