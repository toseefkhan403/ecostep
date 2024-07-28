import 'package:freezed_annotation/freezed_annotation.dart';

part 'action.freezed.dart';
part 'action.g.dart';

@freezed
class Action with _$Action {
  const factory Action({
    required String action,
    required String description,
    required String difficulty,
    required String impact,
    required String impactIfNotDone,
    required String verifiableImage,
  }) = _Action;

  factory Action.fromJson(Map<String, dynamic> json) => _$ActionFromJson(json);
}
