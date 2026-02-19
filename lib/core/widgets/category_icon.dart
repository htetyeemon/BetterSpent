import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;

  const CategoryIcon({super.key, required this.category, this.size = 24});

  IconData _getIconForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'FOOD & DRINK':
        return Icons.restaurant_outlined;
      case 'TRANSPORT':
        return Icons.directions_car_outlined;
      case 'SHOPPING':
        return Icons.shopping_bag_outlined;
      case 'ENTERTAINMENT':
        return Icons.movie_outlined;
      case 'BILLS':
        return Icons.receipt_outlined;
      case 'GROCERY':
        return Icons.shopping_cart_outlined;
      case 'HEALTH':
        return Icons.favorite_outline;
      default:
        return Icons.category_outlined;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'FOOD & DRINK':
        return AppColors.primary;
      case 'TRANSPORT':
        return AppColors.secondary;
      case 'SHOPPING':
        return AppColors.accent;
      case 'ENTERTAINMENT':
        return AppColors.primary;
      case 'BILLS':
        return AppColors.error;
      case 'GROCERY':
        return AppColors.primary;
      case 'HEALTH':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIconForCategory(category),
      size: size,
      color: _getColorForCategory(category),
    );
  }
}
