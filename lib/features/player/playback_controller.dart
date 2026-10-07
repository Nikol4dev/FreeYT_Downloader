import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../download/application/download_queue_provider.dart';
import '../engine/engine_service.dart';
import '../settings/settings_provider.dart';
import 'background_audio.dart';
import 'player_backend.dart';

enum LoopMode { off, all, one }

class PlaybackInfo {
  const PlaybackInfo({
    this.queue = const [],
    this.index = -1,
    this.player,
    this.shuffle = false,
    this.repeat = LoopMode.off,
    this.rate = 1.0,
    this.sleepAt,
    this.sleepAtEnd = false,
    this.error,
  });

  final List<MediaEntity> queue;
  final int index;
  final PlayerBackend? player;
  final bool shuffle;
  final LoopMode repeat;
  final double rate;
  final DateTime? sleepAt;
  final bool sleepAtEnd;
  final String? error;

  MediaEntity? get current => index >= 0 && index < queue.length ? queue[index] : null;
  bool get hasNext => index + 1 < queue.length || repeat == LoopMode.all;
  bool get hasPrevious => index > 0;

  PlaybackInfo copyWith({
    List<MediaEntity>? queue,
    int? index,
    PlayerBackend? player,
    bool? shuffle,
    LoopMode? repeat,
    double? rate,
    DateTime? sleepAt,
    bool? sleepAtEnd,
    String? error,
    bool clearSleep = false,
    bool clearError = false,
  }) => PlaybackInfo(
    queue: queue ?? this.queue,
    index: index ?? this.index,
    player: player ?? this.player,
    shuffle: shuffle ?? this.shuffle,
    repeat: repeat ?? this.repeat,
    rate: rate ?? this.rate,
    sleepAt: clearSleep ? null : (sleepAt ?? this.sleepAt),
    sleepAtEnd: clearSleep ? false : (sleepAtEnd ?? this.sleepAtEnd),
    error: clearError ? null : (error ?? this.error),
  );
}

class PlaybackController extends Notifier<PlaybackInfo> {
  StreamSubscription<void>? _sub;
  Timer? _sleep;
  Timer? _saver;
  bool _advancing = false;
  List<MediaEntity> _original = const [];

  @override
  PlaybackInfo build() {
    backgroundAudio?.onNext = next;
    backgroundAudio?.onPrevious = previous;
    _saver = Timer.periodic(const Duration(seconds: 10), (_) => _savePosition());
    ref.onDispose(() {
      _saver?.cancel();
      _sleep?.cancel();
      _sub?.cancel();
    });
    return const PlaybackInfo();
  }

  Future<void> playList(List<MediaEntity> items, int start, {bool shuffle = false}) async {
    if (items.isEmpty) return;
    _original = items;
    var queue = [...items];
    var index = start.clamp(0, items.length - 1);
    if (shuffle) {
      final first = queue.removeAt(index);
      queue.shuffle(Random());
      queue.insert(0, first);
      index = 0;
    }
    state = state.copyWith(queue: queue, index: index, shuffle: shuffle);
    await _load();
  }

  Future<void> _load() async {
    final m = state.current;
    if (m == null) return;
    await _savePosition();
    await _sub?.cancel();
    _sub = null;
    final old = state.player;
    final player = PlayerBackend();
    state = state.copyWith(player: player, clearError: true);
    if (old != null) {
      backgroundAudio?.detach(old);
      await old.dispose();
    }
    try {
      final uri = m.contentUri;
      await player.open(Platform.isAndroid ? uri : await ref.read(engineProvider).playable(uri));
      await player.setRate(state.rate);
      await player.setLoop(state.repeat == LoopMode.one);
      final fresh = await ref.read(databaseProvider).mediaById(m.id);
      final resume = fresh?.lastPositionMs ?? m.lastPositionMs;
      if (resume > 2000) {
        if (player.duration == Duration.zero) {
          await player.changes.firstWhere((_) => player.duration > Duration.zero).timeout(const Duration(seconds: 10));
        }
        if (resume < player.duration.inMilliseconds - 3000) await player.seek(Duration(milliseconds: resume));
      }
      if (ref.read(settingsProvider).playbackNotification) {
        backgroundAudio?.attach(
          player,
          MediaItem(
            id: m.contentUri,
            title: m.title,
            artist: m.channel.isEmpty ? null : m.channel,
            artUri: m.thumbnailUrl.startsWith('http') ? Uri.parse(m.thumbnailUrl) : null,
            duration: m.durationMs > 0 ? Duration(milliseconds: m.durationMs) : null,
          ),
        );
      }
      _sub = player.changes.listen((_) => _onTick(player));
    } catch (_) {
      if (state.player == player) state = state.copyWith(error: 'Cannot open file');
    }
  }

  void _onTick(PlayerBackend p) {
    if (_advancing || p != state.player) return;
    final d = p.duration;
    if (d > Duration.zero && !p.playing && p.position >= d - const Duration(milliseconds: 400)) {
      _advancing = true;
      _onFinished().whenComplete(() => _advancing = false);
    }
  }

  Future<void> _onFinished() async {
    final m = state.current;
    if (m != null) await ref.read(databaseProvider).savePosition(m.id, 0);
    if (state.sleepAtEnd) {
      state = state.copyWith(clearSleep: true);
      return;
    }
    await next(fromEnd: true);
  }

  Future<void> next({bool fromEnd = false}) async {
    if (state.queue.isEmpty) return;
    var i = state.index + 1;
    if (i >= state.queue.length) {
      if (state.repeat != LoopMode.all) return;
      i = 0;
    }
    if (!fromEnd) await _savePosition();
    state = state.copyWith(index: i);
    await _load();
  }

  Future<void> previous() async {
    final p = state.player;
    if (p != null && (p.position > const Duration(seconds: 3) || state.index == 0)) {
      await p.seek(Duration.zero);
      return;
    }
    if (state.index > 0) {
      state = state.copyWith(index: state.index - 1);
      await _load();
    }
  }

  void toggleShuffle() {
    final cur = state.current;
    if (cur == null) return;
    if (!state.shuffle) {
      final rest = [...state.queue]..removeAt(state.index);
      rest.shuffle(Random());
      state = state.copyWith(queue: [cur, ...rest], index: 0, shuffle: true);
    } else {
      final i = _original.indexWhere((m) => m.id == cur.id);
      state = state.copyWith(queue: _original, index: i < 0 ? 0 : i, shuffle: false);
    }
  }

  void setRepeat(LoopMode mode) {
    state = state.copyWith(repeat: mode);
    state.player?.setLoop(mode == LoopMode.one);
  }

  void setRate(double rate) {
    state = state.copyWith(rate: rate);
    state.player?.setRate(rate);
  }

  void setSleep(Duration? after, {bool endOfVideo = false}) {
    _sleep?.cancel();
    if (endOfVideo) {
      state = state.copyWith(clearSleep: true);
      state = state.copyWith(sleepAtEnd: true);
      return;
    }
    if (after == null) {
      state = state.copyWith(clearSleep: true);
      return;
    }
    state = state.copyWith(clearSleep: true);
    state = state.copyWith(sleepAt: DateTime.now().add(after));
    _sleep = Timer(after, () {
      final p = state.player;
      if (p != null && p.playing) p.playOrPause();
      state = state.copyWith(clearSleep: true);
    });
  }

  Future<void> stop() async {
    await _savePosition();
    _sleep?.cancel();
    await _sub?.cancel();
    _sub = null;
    final p = state.player;
    state = PlaybackInfo(rate: state.rate, repeat: state.repeat);
    if (p != null) {
      backgroundAudio?.detach(p);
      await p.dispose();
    }
  }

  Future<void> _savePosition() async {
    final p = state.player;
    final m = state.current;
    if (p == null || m == null || p.duration == Duration.zero) return;
    await ref.read(databaseProvider).savePosition(m.id, p.position.inMilliseconds);
  }
}

final playbackProvider = NotifierProvider<PlaybackController, PlaybackInfo>(PlaybackController.new);
