import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/labels.dart';
import '../../../widgets/progress_line.dart';
import '../application/download_queue_provider.dart';

class DownloadTaskTile extends ConsumerWidget {
  const DownloadTaskTile({super.key, required this.task});

  final DownloadTask task;

  String get _status {
    switch (task.status) {
      case TaskStatus.pending:
        return task.retries > 0 ? 'Retrying' : 'Queued';
      case TaskStatus.paused:
        return 'Paused · ${(task.progress * 100).toStringAsFixed(0)}%';
      case TaskStatus.completed:
        return 'Saved';
      case TaskStatus.error:
        return task.errorMessage ?? 'Failed';
      case TaskStatus.downloading:
        if (task.progress <= 0) return 'Starting';
        return [
          '${(task.progress * 100).toStringAsFixed(0)}%',
          if (task.speed != null && task.speed!.isNotEmpty) task.speed!,
          if (task.eta != null && task.eta! > 0) '${formatDuration(task.eta!)} left',
        ].join(' · ');
    }
  }

  Color get _accent => switch (task.status) {
    TaskStatus.error => Palette.red,
    TaskStatus.completed => Palette.blue,
    TaskStatus.paused => Palette.textSoft,
    _ => Palette.blue,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.read(downloadQueueProvider.notifier);
    final text = Theme.of(context).textTheme;
    final running = task.status == TaskStatus.downloading || task.status == TaskStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 96,
                    height: 54,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        task.thumbnailUrl.isEmpty
                            ? const ColoredBox(color: Palette.surface2)
                            : Image.network(
                                task.thumbnailUrl,
                                fit: BoxFit.cover,
                                cacheWidth: 288,
                                errorBuilder: (_, _, _) => const ColoredBox(color: Palette.surface2),
                              ),
                        if (task.status == TaskStatus.completed)
                          const ColoredBox(
                            color: Color(0x660B0D12),
                            child: Icon(Icons.check_circle, color: Palette.white),
                          ),
                        if (task.section != null)
                          Positioned(
                            left: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Palette.red, borderRadius: BorderRadius.circular(6)),
                              child: const Text(
                                'CLIP',
                                style: TextStyle(color: Palette.white, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${chipLabel(task.quality)} · $_status',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(color: _accent, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (task.isActive)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: ProgressLine(
                value: task.status == TaskStatus.pending ? 0 : task.progress,
                color: task.status == TaskStatus.paused ? Palette.textSoft : Palette.blue,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (running)
                  IconButton(
                    tooltip: 'Pause',
                    icon: const Icon(Icons.pause_circle_outline),
                    onPressed: () => queue.pause(task.id),
                  ),
                if (task.status == TaskStatus.paused)
                  IconButton(
                    tooltip: 'Resume',
                    color: Palette.blue,
                    icon: const Icon(Icons.play_circle_outline),
                    onPressed: () => queue.resume(task.id),
                  ),
                if (task.status == TaskStatus.error)
                  IconButton(
                    tooltip: 'Retry',
                    color: Palette.blue,
                    icon: const Icon(Icons.refresh),
                    onPressed: () => queue.retry(task.id),
                  ),
                IconButton(
                  tooltip: task.isActive ? 'Cancel' : 'Remove',
                  color: task.isActive ? Palette.red : Palette.textSoft,
                  icon: Icon(task.isActive ? Icons.close : Icons.delete_outline),
                  onPressed: () => task.isActive ? queue.cancel(task.id) : queue.dismiss(task.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
