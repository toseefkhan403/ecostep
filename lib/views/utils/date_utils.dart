import 'package:intl/intl.dart';

String getFormattedDate(DateTime date) {
  DateFormat formatter = DateFormat('E, MMMM d');
  return formatter.format(date);
}

List<String> getWeekday(DateTime date) {
  DateFormat formatter = DateFormat('E');
  DateFormat formatterD = DateFormat('dd');

  return [formatter.format(date), formatterD.format(date)];
}

List<DateTime> getCurrentWeek() {
  DateTime now = DateTime.now();
  int currentWeekday = now.weekday;

  // Calculate the start (Monday) and end (Sunday) of the current week
  DateTime monday = now.subtract(Duration(days: currentWeekday - 1));

  List<DateTime> week = [];
  for (int i = 0; i < 7; i++) {
    week.add(monday.add(Duration(days: i)));
  }

  return week;
}