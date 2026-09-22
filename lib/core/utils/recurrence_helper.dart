import '../../domain/models/recurrence_model.dart';

class RecurrenceHelper {
  RecurrenceHelper._();

  static DateTime? calculateNextDueDate(
    DateTime currentDueDate,
    RecurrenceRule rule,
  ) {
    if (!rule.isRecurring) return null;

    DateTime nextDate;

    switch (rule.type) {
      case RecurrenceType.none:
        return null;

      case RecurrenceType.daily:
        nextDate = currentDueDate.add(Duration(days: rule.interval));
        break;

      case RecurrenceType.weekdays:
        nextDate = currentDueDate.add(const Duration(days: 1));
        // If Saturday (6), move to Monday (+2 days)
        // If Sunday (7), move to Monday (+1 day)
        while (nextDate.weekday == DateTime.saturday ||
            nextDate.weekday == DateTime.sunday) {
          nextDate = nextDate.add(const Duration(days: 1));
        }
        break;

      case RecurrenceType.weekly:
        if (rule.daysOfWeek.isNotEmpty) {
          // Find next matching weekday in daysOfWeek
          DateTime candidate = currentDueDate.add(const Duration(days: 1));
          bool found = false;
          // Look ahead up to 7 * interval days
          final limit = 7 * (rule.interval > 0 ? rule.interval : 1);
          for (int i = 0; i < limit; i++) {
            if (rule.daysOfWeek.contains(candidate.weekday)) {
              found = true;
              break;
            }
            candidate = candidate.add(const Duration(days: 1));
          }
          nextDate = found
              ? candidate
              : currentDueDate.add(Duration(days: 7 * rule.interval));
        } else {
          nextDate = currentDueDate.add(Duration(days: 7 * rule.interval));
        }
        break;

      case RecurrenceType.monthly:
        // Add interval months, keeping day of month safe
        final newMonth = currentDueDate.month + rule.interval;
        final newYear = currentDueDate.year + (newMonth - 1) ~/ 12;
        final normalizedMonth = ((newMonth - 1) % 12) + 1;
        // Clamp day to max days in target month
        final daysInTargetMonth =
            DateTime(newYear, normalizedMonth + 1, 0).day;
        final day = currentDueDate.day > daysInTargetMonth
            ? daysInTargetMonth
            : currentDueDate.day;

        nextDate = DateTime(
          newYear,
          normalizedMonth,
          day,
          currentDueDate.hour,
          currentDueDate.minute,
          currentDueDate.second,
        );
        break;

      case RecurrenceType.custom:
        nextDate = currentDueDate.add(Duration(days: rule.interval));
        break;
    }

    // Check if beyond end date
    if (rule.endDate != null && nextDate.isAfter(rule.endDate!)) {
      return null;
    }

    return nextDate;
  }
}
