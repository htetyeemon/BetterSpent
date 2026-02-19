import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final double height;
  final Color? backgroundColor;

  const CustomProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 8.0,
    this.backgroundColor,
  });

  Color get _progressColor {
    if (color != null) return color!;
    if (progress < 0.5) return AppColors.primary;
    if (progress < 0.75) return AppColors.accent;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: _progressColor,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}
