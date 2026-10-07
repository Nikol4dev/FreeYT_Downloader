class VideoMetadata {
  const VideoMetadata({
    required this.id,
    required this.title,
    required this.channel,
    required this.durationSeconds,
    required this.thumbnailUrl,
    required this.heights,
    this.sizes = const {},
    this.audioSize = 0,
  });

  final String id;
  final String title;
  final String channel;
  final int durationSeconds;
  final String thumbnailUrl;

  final List<int> heights;
  final Map<int, int> sizes;
  final int audioSize;

  int sizeFor(String quality) {
    if (quality.startsWith('Audio')) return audioSize;
    if (sizes.isEmpty) return 0;
    final want = int.tryParse(quality.replaceAll(RegExp(r'\D'), ''));
    final keys = sizes.keys.where((h) => want == null || h <= want).toList()..sort();
    if (keys.isEmpty) return 0;
    return sizes[keys.last]! + audioSize;
  }

  static (Map<int, int>, int) sizesOf(List formats) {
    final sizes = <int, int>{};
    var audio = 0;
    for (final f in formats) {
      if (f is! Map) continue;
      final size = ((f['filesize'] ?? f['filesize_approx']) as num?)?.toInt() ?? 0;
      final h = (f['height'] as num?)?.toInt() ?? 0;
      final video = (f['vcodec'] ?? 'none') != 'none';
      final hasAudio = (f['acodec'] ?? 'none') != 'none';
      if (video && h > 0) {
        if (size > (sizes[h] ?? 0)) sizes[h] = size;
      } else if (!video && hasAudio && size > audio) {
        audio = size;
      }
    }
    return (sizes, audio);
  }

  String get url => 'https://www.youtube.com/watch?v=$id';

  List<String> get qualityOptions {
    const steps = [2160, 1440, 1080, 720, 480, 360];
    final available = heights.isEmpty ? steps : steps.where((s) => heights.any((h) => h >= s));
    return ['Best', for (final s in available) '${s}p', 'Audio (M4A)', 'Audio (MP3)'];
  }

  factory VideoMetadata.fromMap(Map<dynamic, dynamic> m) => VideoMetadata(
    id: m['id'] as String,
    title: (m['title'] as String?) ?? 'Untitled',
    channel: (m['channel'] as String?) ?? '',
    durationSeconds: (m['durationSeconds'] as num?)?.toInt() ?? 0,
    thumbnailUrl: (m['thumbnail'] as String?) ?? '',
    heights: ((m['heights'] as List?) ?? const []).map((e) => (e as num).toInt()).toList(),
    sizes: {
      for (final e in ((m['sizes'] as Map?) ?? const {}).entries) int.parse('${e.key}'): (e.value as num).toInt(),
    },
    audioSize: (m['audioSize'] as num?)?.toInt() ?? 0,
  );
}

class PlaylistInfo {
  const PlaylistInfo({required this.title, required this.entries});

  final String title;
  final List<VideoMetadata> entries;

  factory PlaylistInfo.fromMap(Map<dynamic, dynamic> m) => PlaylistInfo(
    title: (m['title'] as String?) ?? 'Playlist',
    entries: [
      for (final e in (m['entries'] as List? ?? const []))
        VideoMetadata(
          id: (e as Map)['id'] as String,
          title: e['title'] as String? ?? 'Untitled',
          channel: e['channel'] as String? ?? '',
          durationSeconds: (e['durationSeconds'] as num?)?.toInt() ?? 0,
          thumbnailUrl: 'https://i.ytimg.com/vi/${e['id']}/mqdefault.jpg',
          heights: const [],
        ),
    ],
  );
}
