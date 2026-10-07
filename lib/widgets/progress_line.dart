import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class ProgressLine extends StatelessWidget {
  const ProgressLine({super.key, required this.value, this.color = Palette.blue});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Container(
        height: 6,
        decoration: BoxDecoration(color: Palette.surface2, borderRadius: BorderRadius.circular(4)),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(colors: [color, Color.lerp(color, Palette.white, 0.35)!]),
              boxShadow: v > 0 ? [BoxShadow(color: color.withAlpha(150), blurRadius: 10)] : null,
            ),
          ),
        ),
      ),
    );
  }
}
