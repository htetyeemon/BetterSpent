import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class DateSectionWidget extends StatelessWidget {
  final String date;
  final List<Widget> expenses;

  const DateSectionWidget({
    Key? key,
    required this.date,
    required this.expenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.5),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        ...expenses.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
            child: e,
          ),
        ),
      ],
    );
  }
}
