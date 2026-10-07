class YoutubeUrl {
  YoutubeUrl._();

  static final _idPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');
  static final _inText = RegExp(r'(https?://)?((www|m|music)\.)?(youtube\.com|youtu\.be)/\S+', caseSensitive: false);

  static String? extractId(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return null;
    if (!text.startsWith(RegExp(r'https?://', caseSensitive: false))) text = 'https://$text';

    final uri = Uri.tryParse(text);
    if (uri == null) return null;

    final host = uri.host.toLowerCase().replaceFirst(RegExp(r'^(www|m|music)\.'), '');
    String? id;
    if (host == 'youtu.be') {
      id = uri.pathSegments.firstOrNull;
    } else if (host == 'youtube.com') {
      if (uri.path == '/watch') {
        id = uri.queryParameters['v'];
      } else if (uri.pathSegments.length >= 2 &&
          const {'shorts', 'live', 'embed', 'v'}.contains(uri.pathSegments.first)) {
        id = uri.pathSegments[1];
      }
    }
    return (id != null && _idPattern.hasMatch(id)) ? id : null;
  }

  static String? findInText(String text) => _inText.firstMatch(text)?.group(0);

  static bool isPlaylist(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return false;
    if (!text.startsWith(RegExp(r'https?://', caseSensitive: false))) text = 'https://$text';
    final uri = Uri.tryParse(text);
    if (uri == null) return false;
    final host = uri.host.toLowerCase().replaceFirst(RegExp(r'^(www|m|music)\.'), '');
    if (host != 'youtube.com') return false;
    final list = uri.queryParameters['list'];
    if (list == null || list.isEmpty || list.startsWith('RD')) return false;
    return uri.path == '/playlist' || uri.queryParameters['v'] == null;
  }

  static List<String> findAllInText(String text) => [for (final m in _inText.allMatches(text)) m.group(0)!];
}
