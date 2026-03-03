import '../constants/app_constants.dart';

class CategoryHelper {
  const CategoryHelper._();

  static String normalizeLabel(String category) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return 'Other';

    for (final allowed in AppConstants.expenseCategories) {
      if (allowed.toLowerCase() == trimmed.toLowerCase()) {
        return allowed;
      }
    }

    final normalized = trimmed.toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    switch (normalized) {
      case 'FOOD & DRINK':
      case 'FOOD AND DRINK':
        return 'Food & Drink';
      case 'TRANSPORT':
        return 'Transport';
      case 'SHOPPING':
        return 'Shopping';
      case 'ENTERTAINMENT':
        return 'Entertainment';
      case 'BILLS':
      case 'BILLS & UTILITIES':
        return 'Bills';
      case 'GROCERY':
      case 'GROCERIES':
        return 'Grocery';
      case 'HEALTH':
      case 'HEALTHCARE':
        return 'Health';
      case 'OTHER':
      case 'OTHERS':
        return 'Other';
      default:
        return 'Other';
    }
  }
}
