import 'package:ecostep/domain/date.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'week_state.freezed.dart';

@freezed
class WeekState with _$WeekState {
  const factory WeekState({
    required Date selectedDate,
    required List<Date> selectedWeek,
  }) = _WeekState;
}
