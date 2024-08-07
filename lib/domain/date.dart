import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

@immutable
class Date {
  const Date(this.dateTime);

  Date.today() : dateTime = DateTime.now();

  final DateTime dateTime;
  static final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  static final DateFormat _formatter = DateFormat('E, MMMM d');
  static final DateFormat _formatterD = DateFormat('dd');
  static final DateFormat _weekdayFormatter = DateFormat('E');
  static final DateFormat _showFormat = DateFormat('dd MMM yyyy');

  Date add(Duration duration) {
    return Date(dateTime.add(duration));
  }

  Date subtract(Duration duration) {
    return Date(dateTime.subtract(duration));
  }

  bool isBefore(Date other) {
    return dateTime.isBefore(other.dateTime);
  }

  bool isAfter(Date other) {
    return dateTime.isAfter(other.dateTime);
  }

  String getMonthFormattedDate() {
    return _formatter.format(dateTime);
  }

  List<String> getWeekday() {
    return [_weekdayFormatter.format(dateTime), _formatterD.format(dateTime)];
  }

  static List<Date> presentWeek() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;

    // Calculate the start (Monday) and end (Sunday) of the current week
    final monday = now.subtract(Duration(days: currentWeekday - 1));

    final week = <Date>[];
    for (var i = 0; i < 7; i++) {
      week.add(Date(monday.add(Duration(days: i))));
    }

    return week;
  }

  static String getTimeUntilEod() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day + 1);
    final difference = endOfDay.difference(now);

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    return '''${hours.toString().padLeft(2, '0')} hr ${minutes.toString().padLeft(2, '0')} min left''';
  }

  static String formatDateString(String dateStr) {
    final dateTime = _dateFormat.parse(dateStr);
    return _showFormat.format(dateTime);
  }

  @override
  String toString() {
    return _dateFormat.format(dateTime);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Date) return false;
    return dateTime.year == other.dateTime.year &&
        dateTime.month == other.dateTime.month &&
        dateTime.day == other.dateTime.day;
  }

  @override
  int get hashCode =>
      dateTime.year.hashCode ^ dateTime.month.hashCode ^ dateTime.day.hashCode;
}
