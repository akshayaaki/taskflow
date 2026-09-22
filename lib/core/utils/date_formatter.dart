import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatFullDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d, yyyy').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final differenceInDays = target.difference(today).inDays;

    if (differenceInDays == 0) {
      return 'Today at ${formatTime(date)}';
    } else if (differenceInDays == 1) {
      return 'Tomorrow at ${formatTime(date)}';
    } else if (differenceInDays == -1) {
      return 'Yesterday at ${formatTime(date)}';
    } else if (differenceInDays > 1 && differenceInDays < 7) {
      return '${DateFormat('EEEE').format(date)} at ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  static bool isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }
}
