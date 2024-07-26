import 'package:intl/intl.dart';

String getFormattedDate(DateTime date) {
  final formatter = DateFormat('E, MMMM d');
  return formatter.format(date);
}

String getFormattedDateForDb(DateTime date) {
  final formatter = DateFormat('dd-MM-yyyy');
  return formatter.format(date);
}

List<String> getWeekday(DateTime date) {
  final formatter = DateFormat('E');
  final formatterD = DateFormat('dd');

  return [formatter.format(date), formatterD.format(date)];
}

List<DateTime> getCurrentWeek() {
  final now = DateTime.now();
  final currentWeekday = now.weekday;

  // Calculate the start (Monday) and end (Sunday) of the current week
  final monday = now.subtract(Duration(days: currentWeekday - 1));

  final week = <DateTime>[];
  for (var i = 0; i < 7; i++) {
    week.add(monday.add(Duration(days: i)));
  }

  return week;
}

String getTimeUntilEod() {
  // Get the current time
  final now = DateTime.now();

  // Calculate the end of the day (midnight)
  final endOfDay = DateTime(now.year, now.month, now.day + 1);

  // Calculate the difference
  final difference = endOfDay.difference(now);

  // Extract hours and minutes
  final hours = difference.inHours;
  final minutes = difference.inMinutes % 60;

  // Format the remaining time
  return '${hours.toString().padLeft(2, '0')} hr ${minutes.toString().padLeft(2, '0')} min left';
}
