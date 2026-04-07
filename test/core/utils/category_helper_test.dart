import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/core/utils/category_helper.dart';

void main() {
  test('normalizeLabel returns Other for empty', () {
    expect(CategoryHelper.normalizeLabel(''), 'Other');
    expect(CategoryHelper.normalizeLabel('   '), 'Other');
  });

  test('normalizeLabel matches known categories case-insensitively', () {
    expect(CategoryHelper.normalizeLabel('food & drink'), 'Food & Drink');
    expect(CategoryHelper.normalizeLabel('SHOPPING'), 'Shopping');
    expect(CategoryHelper.normalizeLabel('bills & utilities'), 'Bills');
  });

  test('normalizeLabel handles synonyms', () {
    expect(CategoryHelper.normalizeLabel('food and drink'), 'Food & Drink');
    expect(CategoryHelper.normalizeLabel('groceries'), 'Grocery');
    expect(CategoryHelper.normalizeLabel('healthcare'), 'Health');
    expect(CategoryHelper.normalizeLabel('others'), 'Other');
  });
}
