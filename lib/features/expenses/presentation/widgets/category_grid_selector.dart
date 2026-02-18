import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../models/category_option.dart';

class CategoryGridSelector extends StatelessWidget {
  final List<CategoryOption> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryGridSelector({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppConstants.spacingSm,
            mainAxisSpacing: AppConstants.spacingSm,
            childAspectRatio: 1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category.name == selectedCategory;
            return GestureDetector(
              onTap: () => onCategorySelected(category.name),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusLg,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? category.color
                        : AppColors.borderDark,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      size: 24,
                      color: category.color,
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      category.name,
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
