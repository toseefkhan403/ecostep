import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/action.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Action>> fetchActions() async {
    final querySnapshot = await _firestore.collection('actions').get();
    return querySnapshot.docs
        .map((doc) => Action.fromJson(doc.data()))
        .toList();
  }

  Future<void> storeActions(List<Action> actions) async {
    final batch = _firestore.batch();
    final collectionRef = _firestore.collection('actions');

    for (var action in actions) {
      final docRef = collectionRef.doc();
      batch.set(docRef, action.toJson());
    }

    await batch.commit();
  }
}
