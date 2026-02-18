import 'package:intl/intl.dart';

class DateHelper {
  // Format date to "Feb 17, 2026"
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  // Format date to "Today, 8:30 AM"
  static String formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    String prefix;
    if (dateOnly == today) {
      prefix = 'Today';
    } else if (dateOnly == yesterday) {
      prefix = 'Yesterday';
    } else {
      prefix = DateFormat('MMM d').format(date);
    }

    final time = DateFormat('h:mm a').format(date);
    return '$prefix, $time';
  }

  // Format date to uppercase "FEB 17, 2026"
  static String formatDateUppercase(DateTime date) {
    return DateFormat('MMM d, y').format(date).toUpperCase();
  }

  // Get start of week
  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Get end of week
  static DateTime getEndOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  // Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = getStartOfWeek(now);
    final endOfWeek = getEndOfWeek(now);
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
}
