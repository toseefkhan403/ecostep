import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDateController extends StateNotifier<DateTime> {
  SelectedDateController() : super(DateTime.now());

  set selectedDate(DateTime date) {
    state = date;
  }

  DateTime get selectedDate => state;

  bool isSelected(DateTime date) {
    return date.month == state.month &&
        date.day == state.day &&
        date.year == state.year;
  }
}

final selectedDateControllerProvider =
    StateNotifierProvider<SelectedDateController, DateTime>((ref) {
  return SelectedDateController();
});
