// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:json_annotation/json_annotation.dart';

// class TimestampConverter implements JsonConverter<Timestamp, dynamic> {
//   const TimestampConverter();

//   @override
//   Timestamp fromJson(dynamic json) {
//     if (json is Timestamp) {
//       return json;
//     } else if (json is Map<String, dynamic>) {
//       final seconds = json['_seconds'] as int;
//       final nanoseconds = json['_nanoseconds'] as int;
//       return Timestamp(seconds, nanoseconds);
//     } else {
//       throw TypeError();
//     }
//   }

//   @override
//   dynamic toJson(Timestamp object) {
//     return object;
//   }
// }
