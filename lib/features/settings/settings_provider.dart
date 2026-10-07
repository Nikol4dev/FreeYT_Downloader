import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../engine/engine_service.dart';

class AppSettings {
  const AppSettings({
    this.defaultQuality = '1080p',
    this.maxConcurrent = 3,
    this.autoFetch = true,
    this.autoUpdateEngine = true,
    this.lastEngineCheck = 0,
    this.downloadDir = '',
    this.subtitles = false,
    this.subLangs = 'en',
    this.sponsorBlock = false,
  });

  final String defaultQuality;
  final int maxConcurrent;
  final bool autoFetch;
  final bool autoUpdateEngine;
  final int lastEngineCheck;
  final String downloadDir;
  final bool subtitles;
  final String subLangs;
  final bool sponsorBlock;

  AppSettings copyWith({
    String? defaultQuality,
    int? maxConcurrent,
    bool? autoFetch,
    bool? autoUpdateEngine,
    int? lastEngineCheck,
    String? downloadDir,
    bool? subtitles,
    String? subLangs,
    bool? sponsorBlock,
  }) => AppSettings(
    defaultQuality: defaultQuality ?? this.defaultQuality,
    maxConcurrent: maxConcurrent ?? this.maxConcurrent,
    autoFetch: autoFetch ?? this.autoFetch,
    autoUpdateEngine: autoUpdateEngine ?? this.autoUpdateEngine,
    lastEngineCheck: lastEngineCheck ?? this.lastEngineCheck,
    downloadDir: downloadDir ?? this.downloadDir,
    subtitles: subtitles ?? this.subtitles,
    subLangs: subLangs ?? this.subLangs,
    sponsorBlock: sponsorBlock ?? this.sponsorBlock,
  );

  Map<String, Object> toJson() => {
    'defaultQuality': defaultQuality,
    'maxConcurrent': maxConcurrent,
    'autoFetch': autoFetch,
    'autoUpdateEngine': autoUpdateEngine,
    'lastEngineCheck': lastEngineCheck,
    'downloadDir': downloadDir,
    'subtitles': subtitles,
    'subLangs': subLangs,
    'sponsorBlock': sponsorBlock,
  };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
    defaultQuality: j['defaultQuality'] as String? ?? '1080p',
    maxConcurrent: (j['maxConcurrent'] as num?)?.toInt() ?? 3,
    autoFetch: j['autoFetch'] as bool? ?? true,
    autoUpdateEngine: j['autoUpdateEngine'] as bool? ?? true,
    lastEngineCheck: (j['lastEngineCheck'] as num?)?.toInt() ?? 0,
    downloadDir: j['downloadDir'] as String? ?? '',
    subtitles: j['subtitles'] as bool? ?? false,
    subLangs: j['subLangs'] as String? ?? 'en',
    sponsorBlock: j['sponsorBlock'] as bool? ?? false,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    unawaited(_load());
    return const AppSettings();
  }

  Future<File> _file() async => File(p.join((await getApplicationSupportDirectory()).path, 'settings.json'));

  Future<void> _load() async {
    try {
      final f = await _file();
      if (await f.exists()) state = AppSettings.fromJson(jsonDecode(await f.readAsString()) as Map<String, dynamic>);
    } catch (_) {}
    await _updateEngineDaily();
  }

  Future<void> change(AppSettings next) async {
    state = next;
    try {
      await (await _file()).writeAsString(jsonEncode(next.toJson()));
    } catch (_) {}
  }

  Future<void> _updateEngineDaily() async {
    if (!state.autoUpdateEngine) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - state.lastEngineCheck < 86400000) return;
    try {
      await ref.read(engineProvider).updateEngine();
    } catch (_) {}
    await change(state.copyWith(lastEngineCheck: now));
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
