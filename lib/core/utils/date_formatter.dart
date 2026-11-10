import 'package:intl/intl.dart';

/// Formatting utilities for dates and numbers across Persian and English locales.
class DateFormatter {
  DateFormatter._();

  /// Formats a DateTime into a friendly localized date string.
  static String formatDate(DateTime dateTime, String locale) {
    try {
      final formatter = DateFormat.yMMMMd(locale);
      return formatter.format(dateTime);
    } catch (_) {
      // Fallback format if locale data is incomplete
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  /// Formats publication year or returns empty.
  static String formatYear(int? year) {
    if (year == null) return '';
    return year.toString();
  }

  /// Formats quantity with localized digits if needed.
  static String formatQuantity(int quantity, String locale) {
    if (locale == 'fa') {
      const enDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const faDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
      var str = quantity.toString();
      for (var i = 0; i < 10; i++) {
        str = str.replaceAll(enDigits[i], faDigits[i]);
      }
      return str;
    }
    return quantity.toString();
  }
}
