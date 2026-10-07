import 'package:flutter/services.dart';

import '../../models/video_metadata.dart';
import 'engine.dart';

class AndroidEngine implements DownloadEngine {
  static const _method = MethodChannel('com.premium.downloader/ytdlp');
  static const _events = EventChannel('com.premium.downloader/progress');

  @override
  Stream<Map<String, dynamic>> get events =>
      _events.receiveBroadcastStream().where((e) => e is Map).map((e) => Map<String, dynamic>.from(e as Map));

  @override
  Future<VideoMetadata> fetchInfo(String url) async {
    final raw = await _method
        .invokeMapMethod<dynamic, dynamic>('fetchInfo', {'url': url})
        .timeout(const Duration(seconds: 45));
    return VideoMetadata.fromMap(raw!);
  }

  @override
  Future<PlaylistInfo> fetchPlaylist(String url) async {
    final raw = await _method
        .invokeMapMethod<dynamic, dynamic>('fetchPlaylist', {'url': url})
        .timeout(const Duration(seconds: 120));
    return PlaylistInfo.fromMap(raw!);
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
  }) => _method.invokeMethod('startDownload', {
    'taskId': taskId,
    'url': url,
    'title': title,
    'quality': quality,
    'folder': folder,
    'section': section,
    'exactCut': exactCut,
    'subtitles': subtitles,
    'subLangs': subLangs,
    'sponsorBlock': sponsorBlock,
  });

  @override
  Future<List<Map<String, dynamic>>> scanFolder(String folder) async {
    final raw = await _method.invokeListMethod<dynamic>('scanFolder', {'folder': folder});
    if (raw == null) throw Exception('Allow access, then tap Import again');
    return [for (final e in raw) Map<String, dynamic>.from(e as Map)];
  }

  @override
  Future<String> previewUrl(String url) async {
    final link = await _method.invokeMethod<String>('previewUrl', {'url': url}).timeout(const Duration(seconds: 60));
    if (link == null) throw Exception('No preview available');
    return link;
  }

  @override
  Future<String> playable(String uri) async => uri;

  @override
  Future<bool> cancel(String taskId) async =>
      await _method.invokeMethod<bool>('cancelDownload', {'taskId': taskId}) ?? false;

  @override
  Future<bool> pause(String taskId) async =>
      await _method.invokeMethod<bool>('pauseDownload', {'taskId': taskId}) ?? false;

  @override
  Future<bool> isMetered() async => await _method.invokeMethod<bool>('isMetered') ?? false;

  @override
  Future<String?> takeSharedText() => _method.invokeMethod<String>('takeShared');

  @override
  Future<void> ack(String taskId) => _method.invokeMethod('ackEvent', {'taskId': taskId});

  @override
  Future<String> updateEngine() async => await _method.invokeMethod<String>('updateEngine') ?? 'DONE';

  @override
  Future<bool> delete(String uri) async => await _method.invokeMethod<bool>('deleteFile', {'uri': uri}) ?? false;

  @override
  Future<void> open(String uri) async {}
}
