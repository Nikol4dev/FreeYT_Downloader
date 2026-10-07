import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class Backdrop extends StatelessWidget {
  const Backdrop({super.key, required this.child});

  final Widget child;

  static Widget _glow(Color color, double size, int alpha) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withAlpha(alpha), color.withAlpha(0)]),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Palette.bg,
      child: Stack(
        children: [
          Positioned(top: -180, left: -140, child: _glow(Palette.blue, 460, 64)),
          Positioned(bottom: -200, right: -160, child: _glow(Palette.red, 460, 40)),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
