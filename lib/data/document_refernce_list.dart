import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class DocumentReferenceListConverter
    implements JsonConverter<List<DocumentReference>, List<dynamic>> {
  const DocumentReferenceListConverter();

  @override
  List<DocumentReference> fromJson(List<dynamic> json) {
    return json.map((e) => e as DocumentReference).toList();
  }

  @override
  List<dynamic> toJson(List<DocumentReference> object) {
    return object.map((e) => e.path).toList();
  }
}
