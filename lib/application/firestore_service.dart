import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/domain/action.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Assumption: data is generated and stored weekly. It is guaranteed that if
// data for any one day is available, the whole week's data is available
class FirestoreService {
  FirestoreService(this.firestore);

  final FirebaseFirestore firestore;

  Future<List<Action>> fetchActions(DateTime date) async {
    // TODOget current week's actions from 'users'
    final querySnapshot = await firestore.collection('actions').get();
    return querySnapshot.docs
        .map((doc) => Action.fromJson(doc.data()))
        .toList();
  }

  Future<void> storeActions(List<Action> actions) async {
    final batch = firestore.batch();
    final collectionRef = firestore.collection('actions');

    // TODOstore in the current user's collection as well
    for (final action in actions) {
      final docRef = collectionRef.doc();
      batch.set(docRef, action.toJson());
    }

    await batch.commit();
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final firestoreService = FirestoreService(FirebaseFirestore.instance);
  return firestoreService;
});
