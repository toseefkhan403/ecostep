import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/data/document_reference_map_converter.dart';
import 'package:ecostep/data/document_refernce_list.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required int ecoBucksBalance,
    required String joinedOn,
    String? name,
    String? profilePicture,
    int? streak,
    String? lastActionDate,
    String? personalizationString,
    List<String>? completedActionsDates,
    @DocumentReferenceMapConverter()
    Map<String, DocumentReference>? userActions,
    @DocumentReferenceListConverter() List<DocumentReference>? buyerRequests,
    @DocumentReferenceListConverter() List<DocumentReference>? sellerRequests,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
