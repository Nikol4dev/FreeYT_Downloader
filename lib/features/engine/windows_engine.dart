import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

import '../../models/video_metadata.dart';
import 'engine.dart';

class WindowsEngine implements DownloadEngine {
  final _events = StreamController<Map<String, dynamic>>.broadcast();
  final _procs = <String, Process>{};
  final _cancelled = <String>{};

  @override
  Stream<String> get sharedLinks => const Stream.empty();
  final _paused = <String>{};

  @override
  Stream<Map<String, dynamic>> get events => _events.stream;

  Future<String>? _setup;

  Future<String> _dir() async {
    try {
      return await (_setup ??= _resolveTools());
    } catch (_) {
      _setup = null;
      rethrow;
    }
  }

  Map<String, String> _envFor(String dir) => {'PATH': '$dir;${Platform.environment['PATH'] ?? ''}'};

  // Use tools next to the exe, in LOCALAPPDATA or C:\Tools\yt; otherwise download them once.
  Future<String> _resolveTools() async {
    final local = p.join(Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path, 'Downloader', 'tools');
    for (final d in [p.join(File(Platform.resolvedExecutable).parent.path, 'tools'), local, r'C:\Tools\yt']) {
      if (File(p.join(d, 'yt-dlp.exe')).existsSync() && File(p.join(d, 'ffmpeg.exe')).existsSync()) return d;
    }
    Directory(local).createSync(recursive: true);
    final tmp = Directory(p.join(local, 'setup'))..createSync(recursive: true);
    try {
      if (!File(p.join(local, 'yt-dlp.exe')).existsSync()) {
        await _download(
          'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe',
          p.join(local, 'yt-dlp.exe'),
        );
      }
      if (!File(p.join(local, 'deno.exe')).existsSync()) {
        final zip = p.join(tmp.path, 'deno.zip');
        await _download(
          'https://github.com/denoland/deno/releases/latest/download/deno-x86_64-pc-windows-msvc.zip',
          zip,
        );
        await _unzip(zip, local);
      }
      if (!File(p.join(local, 'ffmpeg.exe')).existsSync()) {
        final zip = p.join(tmp.path, 'ffmpeg.zip');
        await _download('https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip', zip);
        final out = p.join(tmp.path, 'ffmpeg');
        await _unzip(zip, out);
        final exe = Directory(out)
            .listSync(recursive: true)
            .whereType<File>()
            .firstWhere((f) => p.basename(f.path).toLowerCase() == 'ffmpeg.exe');
        exe.copySync(p.join(local, 'ffmpeg.exe'));
      }
    } finally {
      try {
        tmp.deleteSync(recursive: true);
      } catch (_) {}
    }
    return local;
  }

  Future<void> _download(String url, String path) async {
    _log('setup download $url');
    final client = HttpClient();
    try {
      final res = await (await client.getUrl(Uri.parse(url))).close();
      if (res.statusCode != 200) throw Exception('Setup download failed (${res.statusCode})');
      await res.pipe(File(path).openWrite());
    } finally {
      client.close();
    }
  }

  Future<void> _unzip(String zip, String dest) async {
    final r = await Process.run('powershell', [
      '-NoProfile',
      '-Command',
      "Expand-Archive -LiteralPath '$zip' -DestinationPath '$dest' -Force",
    ]);
    if (r.exitCode != 0) throw Exception('Setup unzip failed');
  }

  int? _secs(String? s) {
    if (s == null) return null;
    var total = 0;
    for (final part in s.split(':')) {
      final v = int.tryParse(part);
      if (v == null) return null;
      total = total * 60 + v;
    }
    return total;
  }

  @override
  Future<VideoMetadata> fetchInfo(String url) async {
    final dir = await _dir();
    final r = await Process.run(
      p.join(dir, 'yt-dlp.exe'),
      ['-J', '--no-playlist', '--no-warnings', '--socket-timeout', '20', url],
      environment: _envFor(dir),
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ).timeout(const Duration(seconds: 90));
    if (r.exitCode != 0) throw Exception(_lastLine('${r.stderr}'));
    final j = jsonDecode('${r.stdout}') as Map<String, dynamic>;
    final heights = <int>{
      for (final f in (j['formats'] as List? ?? const [])) ((f as Map)['height'] as num?)?.toInt() ?? 0,
    }.where((h) => h > 0).toList()..sort((a, b) => b.compareTo(a));
    final (sizes, audio) = VideoMetadata.sizesOf(j['formats'] as List? ?? const []);
    return VideoMetadata(
      id: j['id'] as String,
      title: j['title'] as String? ?? 'Untitled',
      channel: j['uploader'] as String? ?? '',
      durationSeconds: (j['duration'] as num?)?.toInt() ?? 0,
      thumbnailUrl: j['thumbnail'] as String? ?? '',
      heights: heights,
      sizes: sizes,
      audioSize: audio,
    );
  }

  @override
  Future<PlaylistInfo> fetchPlaylist(String url) async {
    final dir = await _dir();
    final r = await Process.run(
      p.join(dir, 'yt-dlp.exe'),
      ['--flat-playlist', '--dump-single-json', '--no-warnings', '--socket-timeout', '20', url],
      environment: _envFor(dir),
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ).timeout(const Duration(seconds: 180));
    if (r.exitCode != 0) throw Exception(_lastLine('${r.stderr}'));
    final j = jsonDecode('${r.stdout}') as Map<String, dynamic>;
    return PlaylistInfo.fromMap({
      'title': j['title'],
      'entries': [
        for (final e in (j['entries'] as List? ?? const []))
          if (e is Map && '${e['id']}'.length == 11)
            {
              'id': e['id'],
              'title': e['title'],
              'channel': e['uploader'] ?? e['channel'],
              'durationSeconds': e['duration'],
            },
      ],
    });
  }

  @override
  Future<void> start({
    required String taskId,
    required String url,
    required String title,
    required String quality,
    String folder = '',
    String section = '',
    bool exactCut = false,
    bool subtitles = false,
    String subLangs = 'en',
    bool sponsorBlock = false,
    bool notify = true,
  }) async {
    unawaited(_run(taskId, url, title, quality, folder, section, exactCut, subtitles, subLangs, sponsorBlock));
  }

  @override
  Future<List<Map<String, dynamic>>> scanFolder(String folder) async {
    final home = Platform.environment['USERPROFILE'] ?? '.';
    final dirs = folder.trim().isNotEmpty
        ? [folder.trim()]
        : [p.join(home, 'Videos', 'Downloader'), p.join(home, 'Music', 'Downloader')];
    const media = {'.mp4', '.mkv', '.webm', '.m4a', '.mp3', '.opus'};
    const audio = {'.m4a', '.mp3', '.opus'};
    final items = <Map<String, dynamic>>[];
    for (final d in dirs) {
      final dir = Directory(d);
      if (!dir.existsSync()) continue;
      for (final f in dir.listSync().whereType<File>()) {
        final ext = p.extension(f.path).toLowerCase();
        if (!media.contains(ext)) continue;
        items.add({
          'uri': Uri.file(f.path).toString(),
          'name': p.basename(f.path),
          'sizeBytes': f.lengthSync(),
          'durationMs': 0,
          'audio': audio.contains(ext),
        });
      }
    }
    return items;
  }

  @override
  Future<void> openUrl(String url) async {
    await Process.run('rundll32', ['url.dll,FileProtocolHandler', url]);
  }

  @override
  Future<String> previewUrl(String url) async {
    final dir = await _dir();
    final r = await Process.run(
      p.join(dir, 'yt-dlp.exe'),
      ['--no-playlist', '-g', '-f', _previewFormat, '--socket-timeout', '20', url],
      environment: _envFor(dir),
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ).timeout(const Duration(seconds: 60));
    if (r.exitCode != 0) throw Exception(_lastLine('${r.stderr}'));
    return '${r.stdout}'
        .split('\n')
        .map((l) => l.trim())
        .firstWhere((l) => l.startsWith('http'), orElse: () => throw Exception('No preview available'));
  }

  static const _previewFormat =
      '18/best[height<=480][vcodec!=none][acodec!=none]/best[height<=480][vcodec^=avc1]/best[height<=720][vcodec!=none]';

  @override
  Future<String> playable(String uri) async => Uri.parse(uri).toFilePath(windows: true);

  Future<void> _run(
    String id,
    String url,
    String title,
    String quality,
    String folder,
    String section,
    bool exactCut,
    bool subtitles,
    String subLangs,
    bool sponsorBlock,
  ) async {
    final audio = quality.startsWith('Audio');
    Timer? watchdog;
    var watchdogFired = false;
    try {
      final dir = await _dir();
      final custom = folder.trim();
      final base = custom.isNotEmpty
          ? custom
          : p.join(Platform.environment['USERPROFILE'] ?? '.', audio ? 'Music' : 'Videos', 'Downloader');
      final work = Directory(p.join(base, '.tmp', id))..createSync(recursive: true);
      final args = [
        '--no-playlist',
        '--newline',
        '--no-mtime',
        '--continue',
        '--retries',
        '10',
        '--fragment-retries',
        '10',
        '--socket-timeout',
        '20',
        '--concurrent-fragments',
        '4',
        '--embed-metadata',
        '--ffmpeg-location',
        dir,
        '-P',
        work.path,
        '-o',
        'out.%(ext)s',
        if (section.isNotEmpty) ...['--download-sections', section, if (exactCut) '--force-keyframes-at-cuts'],
        if (sponsorBlock) ...['--sponsorblock-remove', 'sponsor,selfpromo'],
        if (subtitles && !audio) ...['--write-subs', '--write-auto-subs', '--sub-langs', subLangs, '--embed-subs'],
        ..._format(quality, audio),
        url,
      ];
      _log('start $id ${args.join(' ')}');
      final proc = await Process.start(p.join(dir, 'yt-dlp.exe'), args, environment: _envFor(dir));
      _procs[id] = proc;
      unawaited(proc.stdin.close().catchError((_) {}));
      _emit(id, 'downloading');

      final phases = audio ? 1 : 2;
      var phase = 0;
      var last = 0.0;
      var best = 0.0;
      final errors = <String>[];

      final out = proc.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        final m = RegExp(r'\[download\]\s+(\d+(?:\.\d+)?)%').firstMatch(line);
        if (m == null) {
          _log(line);
          return;
        }
        final pct = double.parse(m.group(1)!);
        if (pct + 30 < last) phase = min(phase + 1, phases - 1);
        last = pct;
        best = max(best, ((phase * 100 + pct) / (phases * 100)).clamp(0.0, 0.99));
        final speed = RegExp(r'at\s+([\d.]+\s*[KMG]?i?B/s)').firstMatch(line)?.group(1) ?? '';
        final eta = _secs(RegExp(r'ETA\s+([\d:]+)').firstMatch(line)?.group(1));
        _emit(id, 'downloading', best, {'speed': speed, 'eta': eta});
        if (phase == phases - 1 && pct >= 99.9) {
          _log('download pass finished');
          // yt-dlp can hang after the last pass; stop it and keep the finished file.
          watchdog ??= Timer(const Duration(seconds: 150), () {
            watchdogFired = true;
            _log('watchdog: killing process tree');
            unawaited(Process.run('taskkill', ['/PID', '${proc.pid}', '/T', '/F']));
          });
        }
      });
      final err = proc.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        _log('ERR $line');
        errors.add(line);
      });

      final code = await proc.exitCode;
      watchdog?.cancel();
      _log('exit $code');
      await Future.wait([out.asFuture<void>(), err.asFuture<void>()])
          .timeout(const Duration(seconds: 5), onTimeout: () => <void>[]);
      await out.cancel();
      await err.cancel();
      _procs.remove(id);

      if (_paused.remove(id)) {
        _emit(id, 'paused');
        return;
      }
      if (_cancelled.remove(id)) {
        _cleanup(work);
        _emit(id, 'cancelled');
        return;
      }
      if (code != 0 && !watchdogFired) {
        _emit(id, 'error', 0, {'message': _lastLine(errors.join('\n'))});
        return;
      }

      const media = {'.mp4', '.mkv', '.webm', '.m4a', '.mp3', '.opus'};
      File? file;
      for (final f in work.listSync().whereType<File>()) {
        if (p.basenameWithoutExtension(f.path) == 'out' && media.contains(p.extension(f.path).toLowerCase())) file = f;
      }
      _log('output file: ${file?.path}');
      if (file == null) {
        _emit(id, 'error', 0, {
          'message': code != 0 ? _lastLine(errors.join('\n')) : 'Download finished but no output file was found',
        });
        return;
      }

      var name = title.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_').trim();
      if (name.isEmpty) name = id;
      if (name.length > 120) name = name.substring(0, 120);
      final ext = p.extension(file.path);
      var dest = p.join(base, '$name$ext');
      for (var n = 1; File(dest).existsSync(); n++) {
        dest = p.join(base, '$name ($n)$ext');
      }
      try {
        file.renameSync(dest);
      } on FileSystemException {
        file.copySync(dest);
      }
      _log('saved: $dest');
      _cleanup(work);
      _emit(id, 'success', 1, {'uri': Uri.file(dest).toString(), 'sizeBytes': File(dest).lengthSync()});
    } catch (e) {
      _log('error: $e');
      _procs.remove(id);
      _emit(id, 'error', 0, {'message': '$e'.replaceFirst('Exception: ', '')});
    } finally {
      watchdog?.cancel();
    }
  }

  void _log(String line) {
    try {
      File(p.join(Directory.systemTemp.path, 'downloader.log'))
          .writeAsStringSync('${DateTime.now().toIso8601String()} $line\n', mode: FileMode.append);
    } catch (_) {}
  }

  void _cleanup(Directory dir) {
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  }

  List<String> _format(String quality, bool audio) {
    if (audio) {
      return [
        '-f',
        'bestaudio[ext=m4a]/bestaudio/best',
        '-x',
        '--audio-format',
        quality.contains('MP3') ? 'mp3' : 'm4a',
        '--audio-quality',
        '0',
      ];
    }
    final h = quality.replaceAll(RegExp(r'\D'), '');
    final cap = h.isEmpty ? '' : '[height<=$h]';
    return ['-f', 'bv*$cap[ext=mp4]+ba[ext=m4a]/bv*$cap+ba/b$cap', '--merge-output-format', 'mp4'];
  }

  void _emit(String id, String status, [double progress = 0, Map<String, dynamic> extra = const {}]) =>
      _events.add({'taskId': id, 'status': status, 'progress': progress, ...extra});

  String _lastLine(String s) {
    final lines = s.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return 'Unknown error';
    return lines.lastWhere((l) => l.startsWith('ERROR'), orElse: () => lines.last).replaceFirst('ERROR: ', '');
  }

  @override
  Future<bool> cancel(String taskId) async {
    final proc = _procs[taskId];
    if (proc == null) return false;
    _cancelled.add(taskId);
    await Process.run('taskkill', ['/PID', '${proc.pid}', '/T', '/F']);
    return true;
  }

  @override
  Future<bool> pause(String taskId) async {
    final proc = _procs[taskId];
    if (proc == null) return false;
    _paused.add(taskId);
    await Process.run('taskkill', ['/PID', '${proc.pid}', '/T', '/F']);
    return true;
  }

  @override
  Future<bool> isMetered() async => false;

  @override
  Future<String?> takeSharedText() async => null;

  @override
  Future<void> ack(String taskId) async {}

  @override
  Future<String> updateEngine() async {
    final dir = await _dir();
    final r = await Process.run(
      p.join(dir, 'yt-dlp.exe'),
      ['-U'],
      environment: _envFor(dir),
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (r.exitCode != 0) throw Exception(_lastLine('${r.stderr}'));
    return '${r.stdout}'.contains('up to date') ? 'ALREADY_UP_TO_DATE' : 'DONE';
  }

  @override
  Future<bool> delete(String uri) async {
    try {
      final f = File(Uri.parse(uri).toFilePath(windows: true));
      if (f.existsSync()) f.deleteSync();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> open(String uri) async {
    await Process.run('explorer.exe', ['/select,', Uri.parse(uri).toFilePath(windows: true)]);
  }
}
