import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/utils/labels.dart';
import '../../../models/video_metadata.dart';
import '../../engine/engine_service.dart';
import '../../settings/settings_provider.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

enum TaskStatus { pending, downloading, paused, completed, error }

enum EnqueueResult { added, alreadyQueued, alreadyInLibrary }

class DownloadTask {
  const DownloadTask({
    required this.id,
    required this.url,
    required this.title,
    required this.quality,
    this.channel = '',
    this.thumbnailUrl = '',
    this.durationMs = 0,
    this.status = TaskStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
    this.playlist,
    this.section,
    this.exactCut = false,
    this.speed,
    this.eta,
    this.retries = 0,
  });

  final String id;
  final String url;
  final String title;
  final String quality;
  final String channel;
  final String thumbnailUrl;
  final int durationMs;
  final TaskStatus status;
  final double progress;
  final String? errorMessage;
  final String? playlist;
  final String? section;
  final bool exactCut;
  final String? speed;
  final int? eta;
  final int retries;

  bool get isAudio => quality.startsWith('Audio');
  bool get isActive => status == TaskStatus.pending || status == TaskStatus.downloading || status == TaskStatus.paused;

  factory DownloadTask.fromMetadata(VideoMetadata m, String quality, {String? playlist}) => DownloadTask(
    id: m.id,
    url: m.url,
    title: m.title,
    quality: quality,
    channel: m.channel,
    thumbnailUrl: m.thumbnailUrl,
    durationMs: m.durationSeconds * 1000,
    playlist: playlist,
  );

  DownloadTask copyWith({
    TaskStatus? status,
    double? progress,
    String? errorMessage,
    bool clearError = false,
    String? speed,
    int? eta,
    int? retries,
  }) => DownloadTask(
    id: id,
    url: url,
    title: title,
    quality: quality,
    channel: channel,
    thumbnailUrl: thumbnailUrl,
    durationMs: durationMs,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    playlist: playlist,
    section: section,
    exactCut: exactCut,
    speed: speed ?? this.speed,
    eta: eta ?? this.eta,
    retries: retries ?? this.retries,
  );
}

class DownloadQueueNotifier extends Notifier<List<DownloadTask>> {
  StreamSubscription<dynamic>? _sub;
  AppDatabase get _db => ref.read(databaseProvider);

  @override
  List<DownloadTask> build() {
    ref.onDispose(() => _sub?.cancel());
    unawaited(_init());
    return const [];
  }

  // Restore unfinished tasks before listening, so replayed native events find them.
  Future<void> _init() async {
    final rows = await _db.unfinishedTasks();
    final known = state.map((t) => t.id).toSet();
    state = [
      ...rows
          .where((r) => !known.contains(r.id))
          .map(
            (r) => DownloadTask(
              id: r.id,
              url: r.url,
              title: r.title,
              quality: r.preset,
              channel: r.channel,
              thumbnailUrl: r.thumbnailUrl,
              durationMs: r.durationMs,
              status: r.status == 'paused' ? TaskStatus.paused : TaskStatus.pending,
              playlist: r.playlist,
              section: r.section,
              exactCut: r.exactCut,
            ),
          ),
      ...state,
    ];
    _sub = ref.read(engineProvider).events.listen(_onEvent, onError: (_) {});
    _pump();
  }

  Future<EnqueueResult> enqueue(
    VideoMetadata meta,
    String quality, {
    String? playlist,
    int? clipStart,
    int? clipEnd,
    bool exactCut = false,
  }) async {
    final start = clipStart ?? 0;
    final end = clipEnd ?? 0;
    final clip = clipStart != null && clipEnd != null && end > start;
    final id = clip ? '${meta.id}_c$start-$end' : meta.id;
    final existing = _find(id);
    if (existing != null && existing.isActive) return EnqueueResult.alreadyQueued;
    final media = await _db.findMediaByYoutubeId(id);
    if (media != null) {
      if (playlist != null) await _db.addToPlaylist(await _db.findOrCreatePlaylist(playlist), media.id);
      return EnqueueResult.alreadyInLibrary;
    }

    final task = clip
        ? DownloadTask(
            id: id,
            url: meta.url,
            title: '${meta.title} (${formatDuration(start)}–${formatDuration(end)})',
            quality: quality,
            channel: meta.channel,
            thumbnailUrl: meta.thumbnailUrl,
            durationMs: (end - start) * 1000,
            playlist: playlist,
            section: '*$start-$end',
            exactCut: exactCut,
          )
        : DownloadTask.fromMetadata(meta, quality, playlist: playlist);
    state = [...state.where((t) => t.id != id), task];
    await _db.upsertTask(_companion(task));
    _pump();
    return EnqueueResult.added;
  }

  Future<int> enqueueAll(List<VideoMetadata> items, String quality, String? playlist) async {
    var added = 0;
    for (final m in items) {
      if (await enqueue(m, quality, playlist: playlist) == EnqueueResult.added) added++;
    }
    return added;
  }

  Future<void> cancel(String id) async {
    final task = _find(id);
    if (task == null) return;
    if (task.status == TaskStatus.downloading) {
      final killed = await ref.read(engineProvider).cancel(id);
      if (killed) return;
    }
    await dismiss(id);
  }

  Future<void> pause(String id) async {
    final task = _find(id);
    if (task == null) return;
    if (task.status == TaskStatus.downloading && await ref.read(engineProvider).pause(id)) return;
    _patch(id, status: TaskStatus.paused);
    await _db.upsertTask(_companion(task.copyWith(status: TaskStatus.paused)));
    _pump();
  }

  Future<void> resume(String id) async {
    final task = _find(id);
    if (task == null) return;
    _patch(id, status: TaskStatus.pending, clearError: true);
    await _db.upsertTask(_companion(task.copyWith(status: TaskStatus.pending)));
    _pump();
  }

  Future<void> retry(String id) async {
    final task = _find(id);
    if (task == null) return;
    _patch(id, status: TaskStatus.pending, progress: 0, clearError: true);
    await _db.upsertTask(_companion(task.copyWith(status: TaskStatus.pending, progress: 0)));
    _pump();
  }

  Future<void> dismiss(String id) async {
    state = state.where((t) => t.id != id).toList();
    await _db.deleteTask(id);
    _pump();
  }

  void clearFinished() => state = state.where((t) => t.isActive).toList();

  void _pump() {
    var running = state.where((t) => t.status == TaskStatus.downloading).length;
    for (final t in state.where((t) => t.status == TaskStatus.pending).toList()) {
      if (running >= ref.read(settingsProvider).maxConcurrent) break;
      running++;
      unawaited(_start(t));
    }
  }

  Future<void> _start(DownloadTask t) async {
    _patch(t.id, status: TaskStatus.downloading, progress: 0, clearError: true);
    await _db.upsertTask(_companion(t.copyWith(status: TaskStatus.downloading, progress: 0)));
    try {
      await ref
          .read(engineProvider)
          .start(
            taskId: t.id,
            url: t.url,
            title: t.title,
            quality: t.quality,
            folder: ref.read(settingsProvider).downloadDir,
            section: t.section ?? '',
            exactCut: t.exactCut,
            subtitles: ref.read(settingsProvider).subtitles,
            subLangs: ref.read(settingsProvider).subLangs,
            sponsorBlock: ref.read(settingsProvider).sponsorBlock,
          );
    } catch (e) {
      await _fail(t.id, friendlyError(e));
    }
  }

  Future<void> _onEvent(dynamic raw) async {
    if (raw is! Map) return;
    final id = raw['taskId'] as String?;
    final status = raw['status'] as String?;
    if (id == null || status == null) return;

    final task = _find(id);
    if (task == null) {
      if (status != 'downloading') unawaited(_ack(id));
      return;
    }

    switch (status) {
      case 'downloading':
        _patch(
          id,
          status: TaskStatus.downloading,
          progress: (raw['progress'] as num?)?.toDouble() ?? task.progress,
          speed: raw['speed'] as String?,
          eta: (raw['eta'] as num?)?.toInt(),
        );
      case 'success':
        await _onSuccess(task, raw);
      case 'error':
        if (task.retries < 2 && _transient('${raw['message']}')) {
          _patch(id, status: TaskStatus.pending, progress: 0, retries: task.retries + 1);
          await _ack(id);
          Future.delayed(const Duration(seconds: 4), _pump);
        } else {
          await _fail(id, friendlyError(raw['message']));
        }
      case 'paused':
        _patch(id, status: TaskStatus.paused);
        await _db.upsertTask(_companion(task.copyWith(status: TaskStatus.paused)));
        await _ack(id);
        _pump();
      case 'cancelled':
        await dismiss(id);
        await _ack(id);
    }
  }

  Future<void> _onSuccess(DownloadTask task, Map raw) async {
    try {
      await _db.upsertMedia(
        MediaFilesCompanion.insert(
          youtubeId: task.id,
          title: task.title,
          channel: Value(task.channel),
          contentUri: raw['uri'] as String,
          durationMs: task.durationMs,
          fileSizeBytes: Value((raw['sizeBytes'] as num?)?.toInt() ?? 0),
          isAudioOnly: Value(task.isAudio),
          thumbnailUrl: task.thumbnailUrl,
        ),
      );
      final playlist = task.playlist;
      if (playlist != null) {
        final media = await _db.findMediaByYoutubeId(task.id);
        if (media != null) await _db.addToPlaylist(await _db.findOrCreatePlaylist(playlist), media.id);
      }
      await _db.deleteTask(task.id);
      _patch(task.id, status: TaskStatus.completed, progress: 1.0);
      await _ack(task.id);
      _pump();
    } catch (e) {
      await _fail(task.id, 'Save failed: $e');
    }
  }

  Future<void> _fail(String id, String message) async {
    _patch(id, status: TaskStatus.error, errorMessage: message);
    await _db.deleteTask(id);
    await _ack(id);
    _pump();
  }

  DownloadTask? _find(String id) {
    for (final t in state) {
      if (t.id == id) return t;
    }
    return null;
  }

  void _patch(
    String id, {
    TaskStatus? status,
    double? progress,
    String? errorMessage,
    bool clearError = false,
    String? speed,
    int? eta,
    int? retries,
  }) {
    state = [
      for (final t in state)
        if (t.id == id)
          t.copyWith(
            status: status,
            progress: progress,
            errorMessage: errorMessage,
            clearError: clearError,
            speed: speed,
            eta: eta,
            retries: retries,
          )
        else
          t,
    ];
  }

  Future<void> _ack(String id) => ref.read(engineProvider).ack(id);

  DownloadTasksCompanion _companion(DownloadTask t) => DownloadTasksCompanion(
    id: Value(t.id),
    url: Value(t.url),
    title: Value(t.title),
    channel: Value(t.channel),
    thumbnailUrl: Value(t.thumbnailUrl),
    durationMs: Value(t.durationMs),
    preset: Value(t.quality),
    status: Value(t.status.name),
    progress: Value(t.progress),
    playlist: Value(t.playlist),
    section: Value(t.section),
    exactCut: Value(t.exactCut),
  );
}

final downloadQueueProvider = NotifierProvider<DownloadQueueNotifier, List<DownloadTask>>(DownloadQueueNotifier.new);

// Errors that get an automatic retry.
bool _transient(String message) {
  final t = message.toLowerCase();
  return t.contains('timed out') ||
      t.contains('timeout') ||
      t.contains('connection') ||
      t.contains('reset') ||
      t.contains('temporarily') ||
      t.contains('http error 5') ||
      t.contains('unable to download');
}
