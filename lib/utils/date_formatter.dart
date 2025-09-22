import 'package:intl/intl.dart';

class DateFormatter {
  // Format: "dd MMM yyyy" → Contoh: "10 Mei 2025"
  static String formatDate(DateTime date, {String locale = 'id_ID'}) {
    final formatter = DateFormat('dd MMM yyyy', locale);
    return formatter.format(date);
  }

  // Format: "EEE, d MMM yyyy" → Contoh: "Sen, 10 Mei 2025"
  static String formatFullDate(DateTime date, {String locale = 'id_ID'}) {
    final formatter = DateFormat('EEE, d MMM yyyy', locale);
    return formatter.format(date);
  }

  // Format: "HH:mm" → Contoh: "08:30"
  static String formatTime(DateTime date) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }
}