import 'package:intl/intl.dart';

abstract final class AppDateUtils {
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  static String formatDateTime(
    DateTime dateTime, {
    String format = 'yyyy-MM-dd HH:mm',
  }) {
    return DateFormat(format).format(dateTime);
  }

  static String formatTime(DateTime time, {String format = 'hh:mm a'}) {
    return DateFormat(format).format(time);
  }

  static String formatDisplayDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }
}
