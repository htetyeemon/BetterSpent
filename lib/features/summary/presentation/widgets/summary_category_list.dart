import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/usecases/get_spending_by_category_use_case.dart';
import 'category_spending_card.dart';

class SummaryCategoryList extends StatelessWidget {
  final List<CategorySpending> categorySpending;
  final String currencySymbol;

  const SummaryCategoryList({
    super.key,
    required this.categorySpending,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    if (categorySpending.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No spending data yet',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: categorySpending
          .map(
            (cs) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppConstants.spacingMd,
              ),
              child: CategorySpendingCard(
                category: cs.category.toUpperCase(),
                amount: cs.amount,
                percentage: cs.percentage,
                currencySymbol: currencySymbol,
              ),
            ),
          )
          .toList(),
    );
  }
}
