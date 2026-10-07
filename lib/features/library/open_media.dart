import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../player/presentation/player_screen.dart';

void openMedia(BuildContext context, WidgetRef ref, MediaEntity media) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(media: media)));
}
