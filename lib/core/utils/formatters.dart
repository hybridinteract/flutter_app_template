import 'package:intl/intl.dart';

abstract final class AppFormatters {
  static String currency(
    num amount, {
    String symbol = '\$',
    int decimalDigits = 2,
    String? locale,
  }) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
      locale: locale,
    );
    return formatter.format(amount);
  }

  static String compactNumber(num number, {String? locale}) {
    final formatter = NumberFormat.compact(locale: locale);
    return formatter.format(number);
  }

  static String decimal(num number, {int decimalDigits = 2}) {
    final formatter = NumberFormat.decimalPattern();
    formatter.minimumFractionDigits = decimalDigits;
    formatter.maximumFractionDigits = decimalDigits;
    return formatter.format(number);
  }

  static String formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone;
  }
}
