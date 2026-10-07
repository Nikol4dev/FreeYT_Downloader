import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/player/playback_controller.dart';
import '../features/player/presentation/player_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(playbackProvider);
    final m = s.current;
    final p = s.player;
    if (m == null || p == null) return const SizedBox.shrink();
    final ctl = ref.read(playbackProvider.notifier);

    return Material(
      color: Palette.surface2,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen())),
        child: StreamBuilder<void>(
          stream: p.changes,
          builder: (_, _) {
            final d = p.duration.inMilliseconds;
            final f = d > 0 ? (p.position.inMilliseconds / d).clamp(0.0, 1.0) : 0.0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: f,
                  minHeight: 2,
                  color: Palette.red,
                  backgroundColor: Colors.transparent,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 64,
                          height: 36,
                          child: m.thumbnailUrl.startsWith('http')
                              ? Image.network(
                                  m.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  cacheWidth: 192,
                                  errorBuilder: (_, _, _) => const ColoredBox(color: Palette.surface),
                                )
                              : const ColoredBox(
                                  color: Palette.surface,
                                  child: Icon(Icons.music_note, size: 18, color: Palette.textSoft),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            if (m.channel.isNotEmpty)
                              Text(
                                m.channel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Palette.textSoft, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.skip_previous), onPressed: ctl.previous),
                      IconButton(icon: Icon(p.playing ? Icons.pause : Icons.play_arrow), onPressed: p.playOrPause),
                      IconButton(icon: const Icon(Icons.skip_next), onPressed: s.hasNext ? () => ctl.next() : null),
                      IconButton(
                        icon: const Icon(Icons.close, color: Palette.textSoft),
                        onPressed: ctl.stop,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
