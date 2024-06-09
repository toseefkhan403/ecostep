import 'package:flutter/cupertino.dart';

class SelectedDateNotifier extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();

  setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  isSelected(DateTime date) {
    return date.month == selectedDate.month &&
        date.day == selectedDate.day &&
        date.year == selectedDate.year;
  }
}
