import '../../models/video_metadata.dart';

abstract class DownloadEngine {
  Stream<Map<String, dynamic>> get events;
  Future<VideoMetadata> fetchInfo(String url);
  Future<PlaylistInfo> fetchPlaylist(String url);
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
  });
  Future<bool> cancel(String taskId);
  Future<bool> pause(String taskId);
  Future<bool> isMetered();
  Future<String?> takeSharedText();
  Future<void> ack(String taskId);
  Future<String> updateEngine();
  Future<bool> delete(String uri);
  Future<void> open(String uri);
  Future<String> playable(String uri);
  Future<String> previewUrl(String url);
  Future<List<Map<String, dynamic>>> scanFolder(String folder);
}
