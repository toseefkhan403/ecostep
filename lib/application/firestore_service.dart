import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreService {
  FirestoreService(this.firestore);

  final FirebaseFirestore firestore;

  Future<List<DocumentReference>> getAllDocumentReferences(
    String collectionPath,
  ) async {
    final QuerySnapshot snapshot =
        await firestore.collection(collectionPath).get();
    return snapshot.docs.map((doc) => doc.reference).toList();
  }

  Future<void> setDocument(
    DocumentReference ref,
    Map<String, dynamic> data, {
    SetOptions? options,
  }) async {
    await ref.set(data, options ?? SetOptions(merge: false));
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
