String chipLabel(String q) {
  if (q == 'Best') return 'Best';
  if (q.startsWith('Audio')) return q.contains('MP3') ? 'MP3' : 'M4A';
  return q;
}

String formatDuration(int seconds) {
  final h = seconds ~/ 3600, m = (seconds % 3600) ~/ 60, s = seconds % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '$m:${two(s)}';
}

const qualityChoices = ['Best', '2160p', '1440p', '1080p', '720p', '480p', '360p', 'Audio (M4A)', 'Audio (MP3)'];

String formatSize(int bytes) {
  if (bytes >= 1 << 30) return '${(bytes / (1 << 30)).toStringAsFixed(1)} GB';
  return '${(bytes / (1 << 20)).toStringAsFixed(bytes < 10 << 20 ? 1 : 0)} MB';
}

String pickQuality(List<String> options, String pref) {
  if (options.contains(pref)) return pref;
  final want = int.tryParse(pref.replaceAll(RegExp(r'\D'), ''));
  if (want == null) return options.first;
  for (final o in options) {
    final h = int.tryParse(o.replaceAll(RegExp(r'\D'), ''));
    if (!o.startsWith('Audio') && h != null && h <= want) return o;
  }
  return options.first;
}
