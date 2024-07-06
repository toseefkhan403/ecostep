import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required int ecoBucksBalance,
    required bool personalization,
    required DateTime joinedOn,
    String? name,
    String? profilePicture,
    double? impactScore,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
