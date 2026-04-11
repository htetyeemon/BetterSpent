import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/models/expense_model.dart';

void main() {
  group('ExpenseModel - Advanced (Unicode & Round-trip)', () {
    group('String fields with special characters', () {
      test('should handle name with emoji', () {
        final json = {
          'id': '1',
          'name': '☕ Coffee',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.name, contains('☕'));
      });

      test('should handle name with various emoji', () {
        final json = {
          'id': '1',
          'name': 'Lunch 🍕 Pizza',
          'category': 'Food & Drink',
          'amount': 15,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.name, isNotEmpty);
      });

      test('should handle very long name (1000 chars)', () {
        final json = {
          'id': '1',
          'name': 'a' * 1000,
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.name.length, 1000);
      });

      test('should handle empty name string', () {
        final json = {
          'id': '1',
          'name': '',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.name, '');
      });

      test('should handle category with special characters', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink!!!',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.category, contains('!'));
      });

      test('should handle note with newlines and tabs', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
          'note': 'Line1\nLine2\tTab\nLine3',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.note, contains('\n'));
        expect(expense.note, contains('\t'));
      });

      test('should handle ID with special characters', () {
        final json = {
          'id': '!@#\$%^&*()',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.id, contains('!'));
      });

      test('should handle Chinese characters in name', () {
        final json = {
          'id': '1',
          'name': '咖啡',
          'category': '食物',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.name, '咖啡');
      });

      test('should handle Arabic text', () {
        final json = {
          'id': '1',
          'name': 'القهوة',
          'category': 'الطعام',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.name, isNotEmpty);
      });
    });

    group('Round-trip serialization (toJson → fromJson)', () {
      test('should maintain basic data integrity', () {
        final original = ExpenseModel(
          id: '123',
          name: 'Coffee',
          category: 'Food & Drink',
          amount: 5.5,
          date: DateTime(2023, 6, 15, 10, 30, 0),
          note: 'Morning coffee',
        );

        final json = original.toJson();
        final restored = ExpenseModel.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.category, original.category);
        expect(restored.amount, original.amount);
        expect(restored.note, original.note);
      });

      test('should preserve date through round-trip', () {
        final original = ExpenseModel(
          id: '123',
          name: 'Coffee',
          category: 'Food & Drink',
          amount: 5.5,
          date: DateTime(2023, 6, 15, 10, 30, 45),
          note: 'Morning coffee',
        );

        final json = original.toJson();
        final restored = ExpenseModel.fromJson(json);

        // Allow 1-second tolerance for time precision
        expect(restored.date.difference(original.date).inSeconds, lessThan(1));
      });

      test('should handle round-trip with null note', () {
        final original = ExpenseModel(
          id: '123',
          name: 'Coffee',
          category: 'Food & Drink',
          amount: 5.5,
          date: DateTime(2023, 6, 15),
        );

        final json = original.toJson();
        final restored = ExpenseModel.fromJson(json);

        expect(restored.note, isNull);
      });

      test('should preserve Unicode through round-trip', () {
        final original = ExpenseModel(
          id: '123',
          name: '☕ 咖啡',
          category: 'Food & Drink',
          amount: 5.5,
          date: DateTime(2023, 6, 15),
          note: '早上咖啡 🌅',
        );

        final json = original.toJson();
        final restored = ExpenseModel.fromJson(json);

        expect(restored.name, original.name);
        expect(restored.note, original.note);
      });

      test('should preserve special characters through round-trip', () {
        final original = ExpenseModel(
          id: 'id!@#\$%',
          name: 'Test\nName',
          category: 'Category!!!',
          amount: 5.5,
          date: DateTime(2023, 6, 15),
          note: 'Note\twith\ttabs',
        );

        final json = original.toJson();
        final restored = ExpenseModel.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.category, original.category);
        expect(restored.note, original.note);
      });

      test('should handle multiple round-trips', () {
        final original = ExpenseModel(
          id: '123',
          name: 'Coffee',
          category: 'Food & Drink',
          amount: 5.5,
          date: DateTime(2023, 6, 15),
          note: 'Test',
        );

        // Do 3 round-trips
        var current = original;
        for (int i = 0; i < 3; i++) {
          final json = current.toJson();
          current = ExpenseModel.fromJson(json);
        }

        expect(current.id, original.id);
        expect(current.name, original.name);
        expect(current.amount, original.amount);
      });
    });

    group('CopyWith with edge cases', () {
      test('should handle copyWith with negative amount', () {
        final original = ExpenseModel(
          id: '123',
          name: 'Coffee',
          category: 'Food & Drink',
          amount: 5.5,
          date: DateTime(2023, 6, 15),
          note: 'Original',
        );

        final copied = original.copyWith(amount: -10);
        expect(copied.amount, -10);
        expect(copied.id, original.id);
      });

      test('should handle copyWith with empty string', () {
        final original = ExpenseModel(
          id: '123',
          name: 'Coffee',
          category: 'Food & Drink',
          amount: 5.5,
          date: DateTime(2023, 6, 15),
          note: 'Original',
        );

        final copied = original.copyWith(name: '');
        expect(copied.name, '');
        expect(copied.note, 'Original');
      });

      test('should handle copyWith with Unicode', () {
        final original = ExpenseModel(
          id: '123',
          name: 'Coffee',
          category: 'Food & Drink',
          amount: 5.5,
          date: DateTime(2023, 6, 15),
        );

        final copied = original.copyWith(name: '☕ Café');
        expect(copied.name, '☕ Café');
      });

      test('should handle copyWith with new note value', () {
        final original = ExpenseModel(
          id: '123',
          name: 'Coffee',
          category: 'Food & Drink',
          amount: 5.5,
          date: DateTime(2023, 6, 15),
          note: 'Original note',
        );

        final copied = original.copyWith(note: 'Updated note');
        expect(copied.note, 'Updated note');
        expect(copied.name, 'Coffee');
      });

      test('should handle copyWith with new date', () {
        final original = ExpenseModel(
          id: '123',
          name: 'Coffee',
          category: 'Food & Drink',
          amount: 5.5,
          date: DateTime(2023, 6, 15),
        );

        final newDate = DateTime(2024, 12, 25);
        final copied = original.copyWith(date: newDate);
        expect(copied.date, newDate);
        expect(copied.name, original.name);
      });
    });
  });
}
