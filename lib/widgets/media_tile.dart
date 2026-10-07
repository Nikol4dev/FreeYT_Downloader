import 'package:flutter/material.dart';

import '../core/db/app_database.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/labels.dart';

class MediaTile extends StatelessWidget {
  const MediaTile({
    super.key,
    required this.media,
    required this.onOpen,
    this.onFavorite,
    this.menu = const {},
    this.onLongPress,
    this.selected = false,
  });

  final MediaEntity media;
  final VoidCallback onOpen;
  final VoidCallback? onFavorite;
  final Map<String, VoidCallback> menu;
  final VoidCallback? onLongPress;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final watched = media.durationMs > 0 ? (media.lastPositionMs / media.durationMs).clamp(0.0, 1.0) : 0.0;
    final details = [
      if (media.isAudioOnly) 'Audio',
      if (media.channel.isNotEmpty) media.channel,
      if (media.durationMs > 0) formatDuration(media.durationMs ~/ 1000),
      if (media.fileSizeBytes > 0) formatSize(media.fileSizeBytes),
    ].join(' · ');

    return InkWell(
      borderRadius: cardRadius,
      onTap: onOpen,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        decoration: cardDecoration(selected: selected),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 96,
                height: 54,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    media.thumbnailUrl.isEmpty
                        ? const ColoredBox(color: Palette.surface2)
                        : Image.network(
                            media.thumbnailUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 288,
                            errorBuilder: (_, _, _) => const ColoredBox(color: Palette.surface2),
                          ),
                    if (watched > 0.02)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: FractionallySizedBox(
                          widthFactor: watched,
                          child: Container(height: 3, color: Palette.red),
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
                    media.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(color: Palette.textSoft, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (onFavorite != null)
              IconButton(
                icon: Icon(
                  media.isFavorite ? Icons.star : Icons.star_border,
                  color: media.isFavorite ? Palette.blue : Palette.textSoft,
                ),
                onPressed: onFavorite,
              ),
            if (menu.isNotEmpty)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Palette.textSoft),
                onSelected: (k) => menu[k]?.call(),
                itemBuilder: (_) => [for (final k in menu.keys) PopupMenuItem<String>(value: k, child: Text(k))],
              ),
          ],
        ),
      ),
    );
  }
}
