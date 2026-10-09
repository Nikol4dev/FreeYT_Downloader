import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart' as mkv;
import 'package:video_player/video_player.dart' as vp;

// Android uses the system player to keep the app small; Windows uses mpv.
abstract class PlayerBackend {
  factory PlayerBackend() => Platform.isAndroid ? _NativeBackend() : _MpvBackend();

  Stream<void> get changes;
  Duration get position;
  Duration get duration;
  bool get playing;
  List<(String, String)> get subtitles;
  String get subtitle;

  Future<void> open(String source);
  Widget view();
  Future<void> playOrPause();
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration to);
  Future<void> setRate(double rate);
  Future<void> setLoop(bool loop);
  Future<void> toggleMute();
  Future<void> setSubtitle(String id);
  Future<void> dispose();
}

class _MpvBackend implements PlayerBackend {
  _MpvBackend() {
    _subs.add(_p.stream.position.listen((_) => _ctl.add(null)));
    _subs.add(_p.stream.playing.listen((_) => _ctl.add(null)));
    _subs.add(_p.stream.duration.listen((_) => _ctl.add(null)));
    _subs.add(_p.stream.tracks.listen((_) => _ctl.add(null)));
  }

  final mk.Player _p = mk.Player();
  late final mkv.VideoController _c = mkv.VideoController(_p);
  final _ctl = StreamController<void>.broadcast();
  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  Stream<void> get changes => _ctl.stream;
  @override
  Duration get position => _p.state.position;
  @override
  Duration get duration => _p.state.duration;
  @override
  bool get playing => _p.state.playing;
  @override
  List<(String, String)> get subtitles => [
    for (final t in _p.state.tracks.subtitle)
      if (t.id != 'auto' && t.id != 'no') (t.id, t.title ?? t.language ?? t.id),
  ];
  @override
  String get subtitle => _p.state.track.subtitle.id;

  @override
  Future<void> open(String source) => _p.open(mk.Media(source));
  @override
  Widget view() => mkv.Video(controller: _c, controls: mkv.NoVideoControls, fill: Colors.transparent);
  @override
  Future<void> playOrPause() => _p.playOrPause();
  @override
  Future<void> play() => _p.play();
  @override
  Future<void> pause() => _p.pause();
  @override
  Future<void> seek(Duration to) => _p.seek(to);
  @override
  Future<void> setRate(double rate) => _p.setRate(rate);
  @override
  Future<void> setLoop(bool loop) => _p.setPlaylistMode(loop ? mk.PlaylistMode.single : mk.PlaylistMode.none);
  @override
  Future<void> toggleMute() => _p.setVolume(_p.state.volume > 0 ? 0 : 100);
  @override
  Future<void> setSubtitle(String id) async {
    if (id == 'no') return _p.setSubtitleTrack(mk.SubtitleTrack.no());
    for (final t in _p.state.tracks.subtitle) {
      if (t.id == id) return _p.setSubtitleTrack(t);
    }
  }

  @override
  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    await _ctl.close();
    await _p.dispose();
  }
}

class _NativeBackend implements PlayerBackend {
  vp.VideoPlayerController? _c;
  final _ctl = StreamController<void>.broadcast();

  void _tick() {
    if (!_ctl.isClosed) _ctl.add(null);
  }

  @override
  Stream<void> get changes => _ctl.stream;
  @override
  Duration get position => _c?.value.position ?? Duration.zero;
  @override
  Duration get duration => _c?.value.duration ?? Duration.zero;
  @override
  bool get playing => _c?.value.isPlaying ?? false;
  @override
  List<(String, String)> get subtitles => const [];
  @override
  String get subtitle => 'no';

  @override
  Future<void> open(String source) async {
    final uri = Uri.parse(source);
    final options = vp.VideoPlayerOptions(allowBackgroundPlayback: true);
    final c = uri.scheme == 'content'
        ? vp.VideoPlayerController.contentUri(uri, videoPlayerOptions: options)
        : uri.scheme.startsWith('http')
        ? vp.VideoPlayerController.networkUrl(uri, videoPlayerOptions: options)
        : vp.VideoPlayerController.file(File(uri.toFilePath()), videoPlayerOptions: options);
    _c = c;
    c.addListener(_tick);
    await c.initialize();
    await c.play();
    _tick();
  }

  @override
  Widget view() => StreamBuilder<void>(
    stream: changes,
    builder: (_, _) {
      final c = _c;
      if (c == null || !c.value.isInitialized) return const SizedBox();
      return Center(
        child: AspectRatio(aspectRatio: c.value.aspectRatio, child: vp.VideoPlayer(c)),
      );
    },
  );

  @override
  Future<void> playOrPause() async {
    final c = _c;
    if (c == null) return;
    c.value.isPlaying ? await c.pause() : await c.play();
  }

  @override
  Future<void> play() async => _c?.play();

  @override
  Future<void> pause() async => _c?.pause();

  @override
  Future<void> seek(Duration to) async => _c?.seekTo(to);
  @override
  Future<void> setRate(double rate) async => _c?.setPlaybackSpeed(rate);
  @override
  Future<void> setLoop(bool loop) async => _c?.setLooping(loop);
  @override
  Future<void> toggleMute() async {
    final c = _c;
    if (c != null) await c.setVolume(c.value.volume > 0 ? 0 : 1);
  }

  @override
  Future<void> setSubtitle(String id) async {}

  @override
  Future<void> dispose() async {
    _c?.removeListener(_tick);
    await _c?.dispose();
    await _ctl.close();
  }
}
