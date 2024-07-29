import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_string/random_string.dart';

class FirestoreService {
  FirestoreService(this.firestore);

  final FirebaseFirestore firestore;

  Future<void> setDocument(
    DocumentReference ref,
    Map<String, dynamic> data, {
    SetOptions? options,
  }) async {
    await ref.set(data, options);
  }

  Future<DocumentSnapshot> getDocument(DocumentReference ref) async {
    return ref.get();
  }

  Future<void> updateDocument(
    DocumentReference ref,
    Map<String, dynamic> data,
  ) async {
    await ref.update(data);
  }

  Future<List<DocumentSnapshot>> getCollection(CollectionReference ref) async {
    final snapshot = await ref.get();

    return snapshot.docs;
  }

  WriteBatch batch() {
    return firestore.batch();
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});
