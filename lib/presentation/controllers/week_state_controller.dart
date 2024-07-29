import 'package:ecostep/domain/date.dart';
import 'package:ecostep/domain/week_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'week_state_controller.g.dart';

@riverpod
class WeekStateController extends _$WeekStateController {
  @override
  WeekState build() =>
      WeekState(selectedDate: Date.today(), selectedWeek: Date.presentWeek());

  void setSelectedDate(Date date) {
    state = state.copyWith(selectedDate: date);
  }

  bool isSelected(Date date) {
    return date.toString() == state.selectedDate.toString();
  }

  void changeWeek({required bool goBack}) {
    final currentWeek = state.selectedWeek;
    final newWeek = currentWeek.map((date) {
      return date.add(Duration(days: goBack ? -7 : 7));
    }).toList();

    state = state.copyWith(
      selectedWeek: newWeek,
      selectedDate: goBack ? newWeek.last : newWeek.first,
    );
  }
}
