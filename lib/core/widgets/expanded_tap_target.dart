import 'package:flutter/material.dart';

class ExpandedTapTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;

  const ExpandedTapTarget({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Transform.scale(
        scale: scale,
        transformHitTests: true,
        child: Transform.scale(
          scale: 1 / scale,
          transformHitTests: false,
          child: child,
        ),
      ),
    );
  }
}
