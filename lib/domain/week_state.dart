import 'package:freezed_annotation/freezed_annotation.dart';

part 'week_state.freezed.dart';

@freezed
class WeekState with _$WeekState {
  const factory WeekState({
    required DateTime selectedDate,
    required List<DateTime> selectedWeek,
  }) = _WeekState;
}
