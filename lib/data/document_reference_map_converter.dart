import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class DocumentReferenceMapConverter
    implements
        JsonConverter<Map<String, DocumentReference>?, Map<String, dynamic>?> {
  const DocumentReferenceMapConverter();

  @override
  Map<String, DocumentReference>? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return json.map(
      (key, value) => MapEntry(key, value as DocumentReference),
    );
  }

  @override
  Map<String, dynamic>? toJson(Map<String, DocumentReference>? map) {
    if (map == null) return null;
    return map.map((key, value) => MapEntry(key, value.path));
  }
}
