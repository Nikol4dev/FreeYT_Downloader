import 'dart:io' show Platform;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';

import 'core/theme/app_theme.dart';
import 'features/main_nav.dart';
import 'features/player/background_audio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) await windowManager.ensureInitialized();
  if (Platform.isAndroid) {
    try {
      backgroundAudio = await AudioService.init(
        builder: BackgroundAudio.new,
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.premium_downloader.playback',
          androidNotificationChannelName: 'Playback',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );
    } catch (_) {}
  }
  if (!Platform.isAndroid) MediaKit.ensureInitialized();
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Downloader',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const MainNav(),
    );
  }
}
