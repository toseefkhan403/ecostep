import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/application/firebase_auth_service.dart';
import 'package:ecostep/application/firestore_service.dart';
import 'package:ecostep/domain/action.dart';
import 'package:ecostep/domain/date.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth_user;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActionRepository {
  ActionRepository(this.firestoreService, this.currentUser);

  final FirestoreService firestoreService;
  final auth_user.User? currentUser;

  Future<Map<String, dynamic>> fetchUserActions() async {
    if (currentUser == null) return {};

    final userDocRef =
        firestoreService.firestore.collection('users').doc(currentUser?.uid);
    final querySnapshot = await firestoreService.getDocument(userDocRef)
        as DocumentSnapshot<Map<String, dynamic>>;
    return querySnapshot.data()?['userActions'] as Map<String, dynamic>? ?? {};
  }

  Future<void> storeActions(
    List<Action> actions,
    List<Date> week,
  ) async {
    if (currentUser == null) return;

    if (actions.length != 7 || week.length != 7) {
      throw ArgumentError('Both actions and week must have a length of 7');
    }

    final batch = firestoreService.batch();
    final collectionRef = firestoreService.firestore.collection('actions');

    final docRefs = await Future.wait(
      actions.map((action) async {
        final docRef = collectionRef.doc();
        batch.set(docRef, action.toJson());
        return docRef;
      }),
    );

    await batch.commit();

    final userDocRef =
        firestoreService.firestore.collection('users').doc(currentUser?.uid);

    final updates = {
      for (int i = 0; i < week.length; i++) week[i].toString(): docRefs[i],
    };

    await firestoreService.setDocument(
      userDocRef,
      {'userActions': updates},
      options: SetOptions(merge: true),
    );
  }

  Future<Action?> fetchActionFromRef(DocumentReference val) async {
    final actionDoc = await firestoreService.getDocument(val);
    if (actionDoc.exists) {
      final actionData = actionDoc.data()! as Map<String, dynamic>;
      return Action.fromJson(actionData);
    }

    return null;
  }
}

final actionRepositoryProvider = Provider<ActionRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final loggedInUser = ref.watch(authStateProvider).value;
  return ActionRepository(firestoreService, loggedInUser);
});

final actionProvider =
    FutureProvider.family<Action?, DocumentReference>((ref, docRef) {
  final actionRepository = ref.watch(actionRepositoryProvider);
  return actionRepository.fetchActionFromRef(docRef);
});
