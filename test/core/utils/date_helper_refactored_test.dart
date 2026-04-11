import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/core/utils/date_helper.dart';

void main() {
  group('DateHelper - Sad Path Tests', () {
    // Helper functions to reduce repetition
    void testFormatDateReturnsNonEmpty(DateTime date, String description) {
      test(description, () {
        final result = DateHelper.formatDate(date);
        expect(result, isNotEmpty);
      });
    }

    void testMonthEnd(
      int year,
      int month,
      int expectedDay,
      String description,
    ) {
      test(description, () {
        final date = DateTime(year, month, 15);
        final monthEnd = DateHelper.getEndOfMonth(date);
        expect(monthEnd.day, expectedDay);
      });
    }

    group('Edge case dates', () {
      testFormatDateReturnsNonEmpty(
        DateTime(1900, 1, 1),
        'should format date from year 1900',
      );
      testFormatDateReturnsNonEmpty(
        DateTime(2099, 12, 31),
        'should format date from year 2099',
      );
      testFormatDateReturnsNonEmpty(
        DateTime(2023, 12, 31),
        'should format date at year boundary',
      );
      testFormatDateReturnsNonEmpty(
        DateTime(2023, 1, 31),
        'should format date at month boundary',
      );
      testFormatDateReturnsNonEmpty(
        DateTime(2024, 2, 29),
        'should format leap year date (Feb 29)',
      );
      testFormatDateReturnsNonEmpty(
        DateTime(2023, 2, 28),
        'should format non-leap year Feb 28',
      );
    });

    group('DateTime formatting with edge times', () {
      test('should format datetime at midnight', () {
        final date = DateTime(2023, 6, 15, 0, 0, 0);
        final result = DateHelper.formatDateTime(date);
        expect(result, isNotEmpty);
      });

      test('should format datetime at 23:59:59', () {
        final date = DateTime(2023, 6, 15, 23, 59, 59);
        final result = DateHelper.formatDateTime(date);
        expect(result, isNotEmpty);
      });

      test('should format datetime at noon', () {
        final date = DateTime(2023, 6, 15, 12, 0, 0);
        final result = DateHelper.formatDateTime(date);
        expect(result, isNotEmpty);
      });

      test('should format far future and past dates', () {
        final future = DateHelper.formatDateTime(DateTime(2100, 1, 1));
        final past = DateHelper.formatDateTime(DateTime(1970, 1, 1, 8, 30));
        expect(future, isNotEmpty);
        expect(past, isNotEmpty);
      });
    });

    group('Week boundary calculations', () {
      test('should get start of week on Monday', () {
        final wednesday = DateTime(2023, 6, 14);
        final weekStart = DateHelper.getStartOfWeek(wednesday);
        expect(weekStart.weekday, 1); // Monday
      });

      test('should get start of week on Sunday', () {
        final sunday = DateTime(2023, 6, 18);
        final weekStart = DateHelper.getStartOfWeek(sunday);
        expect(weekStart.weekday, 1); // Monday of same week
      });

      test('should get end of week correctly', () {
        final monday = DateTime(2023, 6, 12);
        final weekEnd = DateHelper.getEndOfWeek(monday);
        expect(weekEnd.weekday, 7); // Sunday
      });

      test('should handle week calculations near year boundary', () {
        final date = DateTime(2023, 12, 31);
        final weekStart = DateHelper.getStartOfWeek(date);
        final weekEnd = DateHelper.getEndOfWeek(date);
        expect(weekStart.isBefore(date) || weekStart.day == date.day, true);
        expect(weekEnd.isAfter(date) || weekEnd.day == date.day, true);
      });
    });

    group('Month boundary calculations', () {
      test('should get start of every month on day 1', () {
        for (int month = 1; month <= 12; month++) {
          final date = DateTime(2023, month, 15);
          final monthStart = DateHelper.getStartOfMonth(date);
          expect(monthStart.day, 1);
          expect(monthStart.month, month);
        }
      });

      testMonthEnd(
        2024,
        2,
        29,
        'should get end of February in leap year (2024)',
      );
      testMonthEnd(
        2023,
        2,
        28,
        'should get end of February in non-leap year (2023)',
      );

      test('should get end of 31-day months', () {
        final months = [1, 3, 5, 7, 8, 10, 12];
        for (final month in months) {
          final date = DateTime(2023, month, 15);
          final monthEnd = DateHelper.getEndOfMonth(date);
          expect(monthEnd.day, 31);
        }
      });

      test('should get end of 30-day months', () {
        final months = [4, 6, 9, 11];
        for (final month in months) {
          final date = DateTime(2023, month, 15);
          final monthEnd = DateHelper.getEndOfMonth(date);
          expect(monthEnd.day, 30);
        }
      });
    });

    group('Period checking with edge cases', () {
      test('isToday should return false for tomorrow/yesterday', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DateHelper.isToday(tomorrow), false);
        expect(DateHelper.isToday(yesterday), false);
      });

      test('isToday should return true for today at different times', () {
        final now = DateTime.now();
        final oneHourAgo = now.subtract(const Duration(hours: 1));
        final inOneHour = now.add(const Duration(hours: 1));
        expect(DateHelper.isToday(oneHourAgo), true);
        expect(DateHelper.isToday(inOneHour), true);
      });

      test('isThisWeek should return false for dates 8 days away', () {
        final eightDaysAway = DateTime.now().add(const Duration(days: 8));
        expect(DateHelper.isThisWeek(eightDaysAway), false);
      });

      test('isThisMonth should return false for next/last month', () {
        final now = DateTime.now();
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        final lastMonth = DateTime(now.year, now.month - 1, 15);
        expect(DateHelper.isThisMonth(nextMonth), false);
        expect(DateHelper.isThisMonth(lastMonth), false);
      });

      test('isThisMonth should return true for current month', () {
        expect(DateHelper.isThisMonth(DateTime.now()), true);
      });
    });

    group('ISO date formatting', () {
      test('should format date as ISO with proper zero-padding', () {
        final date = DateTime(2023, 1, 5);
        final result = DateHelper.formatIsoDate(date);
        expect(result, '2023-01-05');
      });

      test('should format double-digit month and day', () {
        final date = DateTime(2023, 12, 25);
        final result = DateHelper.formatIsoDate(date);
        expect(result, '2023-12-25');
      });
    });
  });
}
