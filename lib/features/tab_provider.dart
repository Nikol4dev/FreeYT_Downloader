import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void show(int index) => state = index;
}

final tabProvider = NotifierProvider<TabNotifier, int>(TabNotifier.new);
