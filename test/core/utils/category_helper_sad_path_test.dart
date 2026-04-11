import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/core/utils/category_helper.dart';

void main() {
  group('CategoryHelper - Sad Path Tests', () {
    group('Empty and whitespace inputs', () {
      test('should handle empty string', () {
        final result = CategoryHelper.normalizeLabel('');
        expect(result, 'Other');
      });

      test('should handle only whitespace', () {
        final result = CategoryHelper.normalizeLabel('   ');
        expect(result, 'Other');
      });

      test('should handle tab characters', () {
        final result = CategoryHelper.normalizeLabel('\t\t\t');
        expect(result, 'Other');
      });

      test('should handle newlines', () {
        final result = CategoryHelper.normalizeLabel('\n\n');
        expect(result, 'Other');
      });

      test('should handle mixed whitespace', () {
        final result = CategoryHelper.normalizeLabel('  \t\n  ');
        expect(result, 'Other');
      });
    });

    group('Unicode and special characters', () {
      test('should handle emoji in category', () {
        final result = CategoryHelper.normalizeLabel('Food 🍔');
        expect(result, isNotEmpty);
      });

      test('should handle Chinese characters', () {
        final result = CategoryHelper.normalizeLabel('食物');
        expect(result, 'Other');
      });

      test('should handle Arabic characters', () {
        final result = CategoryHelper.normalizeLabel('طعام');
        expect(result, 'Other');
      });

      test('should handle Cyrillic characters', () {
        final result = CategoryHelper.normalizeLabel('Развлечение');
        expect(result, 'Other');
      });

      test('should handle mixed language text', () {
        final result = CategoryHelper.normalizeLabel('Food食物');
        expect(result, isNotEmpty);
      });

      test('should handle only emojis', () {
        final result = CategoryHelper.normalizeLabel('🍔🚗🎬');
        expect(result, 'Other');
      });

      test('should handle accented characters', () {
        final result = CategoryHelper.normalizeLabel('Café');
        expect(result, isNotEmpty);
      });

      test('should handle combining marks/diacritics', () {
        final result = CategoryHelper.normalizeLabel(
          'e\u0301',
        ); // é as e + combining acute
        expect(result, isNotEmpty);
      });
    });

    group('Case variations and normalization', () {
      test('should handle lowercase food&drink', () {
        final result = CategoryHelper.normalizeLabel('food & drink');
        expect(result, 'Food & Drink');
      });

      test('should handle uppercase FOOD&DRINK', () {
        final result = CategoryHelper.normalizeLabel('FOOD & DRINK');
        expect(result, 'Food & Drink');
      });

      test('should handle mixed case FoOd & DrInK', () {
        final result = CategoryHelper.normalizeLabel('FoOd & DrInK');
        expect(result, 'Food & Drink');
      });

      test('should handle food and drink variant', () {
        final result = CategoryHelper.normalizeLabel('food and drink');
        expect(result, 'Food & Drink');
      });

      test('should handle extra spaces in category', () {
        final result = CategoryHelper.normalizeLabel('  food    &    drink  ');
        expect(result, 'Food & Drink');
      });

      test('should handle multiple consecutive spaces', () {
        final result = CategoryHelper.normalizeLabel('Food  &  Drink');
        expect(result, isNotEmpty);
      });
    });

    group('Unrecognized categories', () {
      test('should default unrecognized category to Other', () {
        final result = CategoryHelper.normalizeLabel('Random Category');
        expect(result, 'Other');
      });

      test('should default completely random string to Other', () {
        final result = CategoryHelper.normalizeLabel('xyzabc123!@#');
        expect(result, 'Other');
      });

      test('should default gibberish to Other', () {
        final result = CategoryHelper.normalizeLabel('qwerty asdfgh');
        expect(result, 'Other');
      });

      test('should handle single letter', () {
        final result = CategoryHelper.normalizeLabel('X');
        expect(result, 'Other');
      });

      test('should handle numeric only input', () {
        final result = CategoryHelper.normalizeLabel('12345');
        expect(result, 'Other');
      });

      test('should handle special characters only', () {
        final result = CategoryHelper.normalizeLabel('!@#\$%^&*()');
        expect(result, 'Other');
      });
    });

    group('Very long inputs', () {
      test('should handle very long category name', () {
        final longName = 'a' * 1000;
        final result = CategoryHelper.normalizeLabel(longName);
        expect(result, 'Other');
      });

      test('should handle category with many spaces', () {
        final result = CategoryHelper.normalizeLabel('food ' * 100);
        expect(result, isNotEmpty);
      });
    });

    group('Variant spellings and similar words', () {
      test('should handle transport variant', () {
        final result = CategoryHelper.normalizeLabel('TRANSPORT');
        expect(result, 'Transport');
      });

      test('should handle shopping variant', () {
        final result = CategoryHelper.normalizeLabel('shopping');
        expect(result, 'Shopping');
      });

      test('should handle entertainment variant', () {
        final result = CategoryHelper.normalizeLabel('ENTERTAINMENT');
        expect(result, 'Entertainment');
      });

      test('should handle bill variations', () {
        final result1 = CategoryHelper.normalizeLabel('bills');
        final result2 = CategoryHelper.normalizeLabel('bills & utilities');
        expect(result1, 'Bills');
        expect(result2, 'Bills');
      });

      test('should handle grocery plurals', () {
        final result = CategoryHelper.normalizeLabel('groceries');
        expect(result, 'Grocery');
      });

      test('should handle health variations', () {
        final result1 = CategoryHelper.normalizeLabel('health');
        final result2 = CategoryHelper.normalizeLabel('healthcare');
        expect(result1, 'Health');
        expect(result2, 'Health');
      });

      test('should handle other and others', () {
        final result1 = CategoryHelper.normalizeLabel('other');
        final result2 = CategoryHelper.normalizeLabel('others');
        expect(result1, 'Other');
        expect(result2, 'Other');
      });
    });

    group('Boundary between recognized and unrecognized', () {
      test('should recognize Food & Drink exactly', () {
        final result = CategoryHelper.normalizeLabel('Food & Drink');
        expect(result, 'Food & Drink');
      });

      test('should not recognize Food & Drinks (plural)', () {
        final result = CategoryHelper.normalizeLabel('Food & Drinks');
        expect(result, 'Other');
      });

      test('should recognize Grocery not Groceria', () {
        final result = CategoryHelper.normalizeLabel('Groceria');
        expect(result, 'Other');
      });
    });

    group('Symbols and punctuation combinations', () {
      test('should handle multiple ampersands', () {
        final result = CategoryHelper.normalizeLabel('food & & drink');
        expect(result, isNotEmpty);
      });

      test('should handle forward slash', () {
        final result = CategoryHelper.normalizeLabel('Food/Drink');
        expect(result, isNotEmpty);
      });

      test('should handle hyphens', () {
        final result = CategoryHelper.normalizeLabel('Food-Drink');
        expect(result, isNotEmpty);
      });

      test('should handle parentheses', () {
        final result = CategoryHelper.normalizeLabel('Food (Drinks)');
        expect(result, isNotEmpty);
      });
    });
  });
}
