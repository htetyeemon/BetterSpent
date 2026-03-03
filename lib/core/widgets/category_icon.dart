import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/category_helper.dart';

class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;

  const CategoryIcon({super.key, required this.category, this.size = 24});

  static IconData iconForCategory(String category) {
    switch (CategoryHelper.normalizeLabel(category)) {
      case 'Food & Drink':
        return Icons.restaurant_outlined;
      case 'Transport':
        return Icons.directions_car_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Entertainment':
        return Icons.movie_outlined;
      case 'Bills':
        return Icons.receipt_outlined;
      case 'Grocery':
        return Icons.shopping_cart_outlined;
      case 'Health':
        return Icons.favorite_outline;
      case 'Other':
        return Icons.category_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  static Color colorForCategory(String category) {
    switch (CategoryHelper.normalizeLabel(category)) {
      case 'Food & Drink':
        return AppColors.primary;
      case 'Transport':
        return AppColors.secondary;
      case 'Shopping':
        return AppColors.accent;
      case 'Entertainment':
        return AppColors.primary;
      case 'Bills':
        return AppColors.error;
      case 'Grocery':
        return AppColors.primary;
      case 'Health':
        return AppColors.error;
      case 'Other':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconForCategory(category),
      size: size,
      color: colorForCategory(category),
    );
  }
}
