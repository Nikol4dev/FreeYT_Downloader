import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/backdrop.dart';
import '../widgets/mini_player.dart';
import 'download/presentation/home_screen.dart';
import 'library/presentation/library_screen.dart';
import 'settings/settings_screen.dart';
import 'tab_provider.dart';

class MainNav extends ConsumerWidget {
  const MainNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabProvider);
    return Scaffold(
      body: Backdrop(
        child: IndexedStack(index: index, children: const [HomeScreen(), LibraryScreen(), SettingsScreen()]),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: index,
            onDestinationSelected: ref.read(tabProvider.notifier).show,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.download_outlined),
                selectedIcon: Icon(Icons.download),
                label: 'Save',
              ),
              NavigationDestination(
                icon: Icon(Icons.video_library_outlined),
                selectedIcon: Icon(Icons.video_library),
                label: 'Library',
              ),
              NavigationDestination(icon: Icon(Icons.tune), selectedIcon: Icon(Icons.tune), label: 'Settings'),
            ],
          ),
        ],
      ),
    );
  }
}
