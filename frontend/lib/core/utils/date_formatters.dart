import 'package:intl/intl.dart';

class DateFormatters {
  static String display(DateTime date) => DateFormat('MMM dd, yyyy').format(date);
  static String displayWithTime(DateTime date) => DateFormat('MMM dd, yyyy – h:mm a').format(date);
  static String iso(DateTime date) => date.toIso8601String();
  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return display(date);
  }
}
