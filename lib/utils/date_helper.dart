import 'package:intl/intl.dart';

/// Formats [dateTime] into a human-readable Indonesian locale string,
/// e.g. "23 Juli 2026, 08:15".
///
/// Requires `initializeDateFormatting('id')` to be called once at app startup
/// (typically in `main()` via `Intl.defaultLocale = 'id'` or
/// `initializeDateFormatting('id_ID')`).
String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'id');
  return formatter.format(dateTime);
}

/// Formats [dateTime] to 24-hour time only, e.g. "08:15".
String formatTime(DateTime dateTime) {
  final formatter = DateFormat('HH:mm');
  return formatter.format(dateTime);
}
