import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_info.dart';
import 'settings_provider.dart';

typedef Update = ({String version, String url});

final updateProvider = FutureProvider<Update?>((ref) async {
  if (!ref.watch(settingsProvider.select((s) => s.checkUpdates))) return null;
  if (githubRepo.startsWith('YOUR-')) return null;
  final client = HttpClient();
  try {
    final req = await client.getUrl(Uri.parse('https://api.github.com/repos/$githubRepo/releases/latest'));
    req.headers.set('User-Agent', 'Downloader');
    req.headers.set('Accept', 'application/vnd.github+json');
    final res = await req.close().timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final j = jsonDecode(await res.transform(utf8.decoder).join()) as Map<String, dynamic>;
    final tag = (j['tag_name'] as String? ?? '').replaceFirst(RegExp('^v'), '');
    return _newer(tag, appVersion) ? (version: tag, url: j['html_url'] as String) : null;
  } catch (_) {
    return null;
  } finally {
    client.close();
  }
});

bool _newer(String a, String b) {
  List<int> parts(String v) => [for (final p in v.split('.')) int.tryParse(p) ?? 0];
  final x = parts(a), y = parts(b);
  for (var i = 0; i < 3; i++) {
    final xi = i < x.length ? x[i] : 0, yi = i < y.length ? y[i] : 0;
    if (xi != yi) return xi > yi;
  }
  return false;
}
