import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../player/playback_controller.dart';
import '../player/presentation/player_screen.dart';

void openMedia(BuildContext context, WidgetRef ref, List<MediaEntity> items, int index, {bool shuffle = false}) {
  ref.read(playbackProvider.notifier).playList(items, index, shuffle: shuffle);
  Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
}
