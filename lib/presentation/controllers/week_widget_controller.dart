import 'package:ecostep/domain/week_state.dart';
import 'package:ecostep/presentation/utils/date_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'week_widget_controller.g.dart';

@riverpod
class WeekWidgetController extends _$WeekWidgetController {
  @override
  WeekState build() =>
      WeekState(selectedDate: DateTime.now(), selectedWeek: getCurrentWeek());

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  bool isSelected(DateTime date) {
    return date.month == state.selectedDate.month &&
        date.day == state.selectedDate.day &&
        date.year == state.selectedDate.year;
  }

  void changeWeek({required bool goBack}) {
    final currentWeek = state.selectedWeek;
    final newWeek = currentWeek.map((date) {
      return date.add(Duration(days: goBack ? -7 : 7));
    }).toList();

    state = state.copyWith(selectedWeek: newWeek);
  }
}
