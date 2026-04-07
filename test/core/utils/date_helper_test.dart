import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:better_spent/core/utils/date_helper.dart';

void main() {
  setUpAll(() {
    Intl.defaultLocale = 'en_US';
  });

  test('formatDate uses MMM d, y', () {
    final date = DateTime(2026, 2, 17);
    expect(DateHelper.formatDate(date), 'Feb 17, 2026');
  });

  test('formatDateUppercase uppercases formatted date', () {
    final date = DateTime(2026, 2, 17);
    expect(DateHelper.formatDateUppercase(date), 'FEB 17, 2026');
  });

  test('formatIsoDate uses yyyy-MM-dd', () {
    final date = DateTime(2026, 2, 7);
    expect(DateHelper.formatIsoDate(date), '2026-02-07');
  });

  test('formatDateTime uses Today and Yesterday prefixes', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 8, 30);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayExpected = 'Today, ${DateFormat('h:mm a').format(today)}';
    final yesterdayExpected = 'Yesterday, ${DateFormat('h:mm a').format(yesterday)}';

    expect(DateHelper.formatDateTime(today), todayExpected);
    expect(DateHelper.formatDateTime(yesterday), yesterdayExpected);
  });

  test('getStartOfWeek and getEndOfWeek return week bounds', () {
    final date = DateTime(2026, 3, 11); // Wednesday
    final start = DateHelper.getStartOfWeek(date);
    final end = DateHelper.getEndOfWeek(date);

    expect(start.weekday, DateTime.monday);
    expect(end.weekday, DateTime.sunday);
  });

  test('getStartOfMonth and getEndOfMonth return month bounds', () {
    final date = DateTime(2026, 2, 15);
    expect(DateHelper.getStartOfMonth(date), DateTime(2026, 2, 1));
    expect(DateHelper.getEndOfMonth(date), DateTime(2026, 2, 28));
  });

  test('isToday, isThisWeek, isThisMonth behave as expected', () {
    final now = DateTime.now();
    expect(DateHelper.isToday(now), isTrue);
    expect(DateHelper.isThisWeek(now), isTrue);
    expect(DateHelper.isThisMonth(now), isTrue);

    final oldDate = now.subtract(const Duration(days: 40));
    expect(DateHelper.isToday(oldDate), isFalse);
    expect(DateHelper.isThisMonth(oldDate), isFalse);
  });
}
