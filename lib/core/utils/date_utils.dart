import 'package:intl/intl.dart';

/// Utilidades de fecha para el formato estandarizado 'YYYY-MM-DD' y cálculos devocionales.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _ymdFormat = DateFormat('yyyy-MM-dd');

  /// Formatea un DateTime a 'YYYY-MM-DD'
  static String toYmd(DateTime date) {
    return _ymdFormat.format(date);
  }

  /// Parsea un String 'YYYY-MM-DD' a DateTime (a las 00:00:00 local)
  static DateTime fromYmd(String ymd) {
    return _ymdFormat.parse(ymd);
  }

  /// Normaliza una fecha eliminando horas, minutos y segundos (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Retorna true si la fecha corresponde al día de hoy
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Retorna true si la fecha transcurrió dentro de las últimas N horas
  static bool isWithinLastHours(DateTime? date, int hours) {
    if (date == null) return false;
    final difference = DateTime.now().difference(date);
    return !difference.isNegative && difference.inHours <= hours;
  }

  /// Retorna true si han pasado más de N horas desde la fecha
  static bool hasPassedMoreThanHours(DateTime? date, int hours) {
    if (date == null) return true;
    final difference = DateTime.now().difference(date);
    return difference.inHours > hours;
  }
}
