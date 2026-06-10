import 'package:intl/intl.dart';

/// Date and time formatting utilities.
abstract final class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, yyyy • h:mm a');
  static final DateFormat _shortDate = DateFormat('EEE, MMM d');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatTime(DateTime date) => _timeFormat.format(date);

  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  static String formatShortDate(DateTime date) => _shortDate.format(date);

  static String relativeDueDate(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = due.difference(today).inDays;

    if (diff == 0) return 'Today, ${formatTime(dueDate)}';
    if (diff == 1) return 'Tomorrow, ${formatTime(dueDate)}';
    if (diff == -1) return 'Yesterday, ${formatTime(dueDate)}';
    if (diff < 0) return 'Overdue • ${formatDateTime(dueDate)}';
    return formatDateTime(dueDate);
  }
}
