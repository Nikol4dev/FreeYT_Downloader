import 'dart:async';

import 'package:audio_service/audio_service.dart';

import 'player_backend.dart';

// Android only: lock-screen and notification controls, keeps playback alive in the background.
BackgroundAudio? backgroundAudio;

class BackgroundAudio extends BaseAudioHandler with SeekHandler {
  Future<void> Function()? onNext;
  Future<void> Function()? onPrevious;
  PlayerBackend? _player;
  StreamSubscription<void>? _sub;
  bool? _lastPlaying;
  DateTime _lastSent = DateTime(0);

  void attach(PlayerBackend player, MediaItem item) {
    _sub?.cancel();
    _player = player;
    _lastPlaying = null;
    mediaItem.add(item);
    _sub = player.changes.listen((_) => _broadcast());
    _broadcast();
  }

  void detach(PlayerBackend player) {
    if (_player != player) return;
    _sub?.cancel();
    _sub = null;
    _player = null;
    playbackState.add(playbackState.value.copyWith(processingState: AudioProcessingState.idle, playing: false));
  }

  void _broadcast() {
    final p = _player;
    if (p == null) return;
    final now = DateTime.now();
    if (p.playing == _lastPlaying && now.difference(_lastSent) < const Duration(seconds: 1)) return;
    _lastPlaying = p.playing;
    _lastSent = now;
    final item = mediaItem.value;
    if (item != null && item.duration == null && p.duration > Duration.zero) {
      mediaItem.add(item.copyWith(duration: p.duration));
    }
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          p.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.ready,
        playing: p.playing,
        updatePosition: p.position,
      ),
    );
  }

  Future<void> _skip(int seconds) async {
    final p = _player;
    if (p == null) return;
    var target = p.position + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (p.duration > Duration.zero && target > p.duration) target = p.duration;
    await p.seek(target);
  }

  @override
  Future<void> play() async {
    final p = _player;
    if (p != null && !p.playing) await p.playOrPause();
  }

  @override
  Future<void> pause() async {
    final p = _player;
    if (p != null && p.playing) await p.playOrPause();
  }

  @override
  Future<void> seek(Duration position) async => _player?.seek(position);

  @override
  Future<void> rewind() => _skip(-10);

  @override
  Future<void> fastForward() => _skip(10);

  @override
  Future<void> skipToNext() async => onNext?.call();

  @override
  Future<void> skipToPrevious() async => onPrevious?.call();

  @override
  Future<void> stop() => pause();
}
