// ignore_for_file: omit_local_variable_types
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/application/firebase_auth_service.dart';
import 'package:ecostep/domain/action.dart';
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:ecostep/domain/user.dart';
import 'package:ecostep/presentation/utils/date_utils.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth_user;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_string/random_string.dart';

// Assumption: data is generated and stored weekly. It is guaranteed that if
// data for any one day is available, the whole week's data is available
class FirestoreService {
  FirestoreService(this.firestore, this.currentUser);

  final FirebaseFirestore firestore;
  final auth_user.User? currentUser;

  Future<List<MarketplaceItem>> fetchMarketplaceItems() async {
    try {
      final QuerySnapshot snapshot =
          await firestore.collection('marketplaceItems').get();
      final List<MarketplaceItem> items = snapshot.docs.map((doc) {
        final data = doc.data()! as Map<String, dynamic>;
        return MarketplaceItem.fromJson(data);
      }).toList();
      return items;
    } catch (e) {
      debugPrint('Error fetching marketplace items: $e');
      rethrow;
    }
  }

  Future<void> sendPurchaseRequest(MarketplaceItem item) async {
    if (currentUser == null) {
      throw StateError('No user is currently logged in');
    }

    final String currentUserUid = currentUser!.uid;
    final String purchaseRequestId = randomAlphaNumeric(12);
    final DocumentReference buyerRef =
        firestore.collection('users').doc(currentUserUid);
    final DocumentReference itemRef =
        firestore.collection('marketplaceItems').doc(item.docid);
    final DocumentReference sellerRef = item.sellingUser as DocumentReference;
    final Timestamp timestamp = Timestamp.now();

    final Map<String, dynamic> purchaseRequestData = {
      'buyerId': buyerRef,
      'item': itemRef,
      'sellerId': sellerRef,
      'timestamp': timestamp,
    };

    try {
      await firestore
          .collection('purchaseRequests')
          .doc(purchaseRequestId)
          .set(purchaseRequestData);

      final DocumentReference purchaseRequestRef =
          firestore.collection('purchaseRequests').doc(purchaseRequestId);
      await sellerRef.update(
        {
          'purchaseRequests': FieldValue.arrayUnion([purchaseRequestRef]),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending purchase request: $e');
      }

      rethrow;
    }
  }

  Future<List<Action>> fetchActions(List<DateTime> currentWeek) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();

    final userActions =
        querySnapshot.data()?['userActions'] as Map<String, dynamic>?;

    if (userActions == null) {
      return [];
    }

    return fetchActionsFromRefsMap(currentWeek, userActions);
  }

  Future<void> storeActions(
    List<Action> actions,
    List<DateTime> currentWeek,
  ) async {
    if (actions.length != 7 || currentWeek.length != 7) {
      throw ArgumentError(
        'Both actions and currentWeek must have a length of 7',
      );
    }

    final batch = firestore.batch();
    final collectionRef = firestore.collection('actions');

    final docRefs = <DocumentReference>[];
    for (final action in actions) {
      final docRef = collectionRef.doc();
      docRefs.add(docRef);
      batch.set(docRef, action.toJson());
    }

    await batch.commit();

    final userDocRef = firestore.collection('users').doc(currentUser?.uid);

    final updates = <String, DocumentReference>{};
    for (var i = 0; i < 7; i++) {
      updates[getFormattedFullDate(currentWeek[i])] = docRefs[i];
    }

    await userDocRef.update(
      {
        'userActions': updates,
      },
    );
  }

  Future<void> createUserIfDoesntExist(User user) async {
    if (await doesUserExist(user.id)) return;

    await firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<bool> doesUserExist(String? uid) async {
    final querySnapshot = await firestore.collection('users').doc(uid).get();
    return querySnapshot.exists;
  }

  Future<List<Action>> fetchActionsFromRefsMap(
    List<DateTime> currentWeek,
    Map<String, dynamic> userActions,
  ) async {
    final actions = <Action>[];

    // get actions from docRefs
    for (final date in currentWeek) {
      final actionDoc =
          await (userActions[getFormattedFullDate(date)] as DocumentReference)
              .get();
      if (actionDoc.exists) {
        final actionData = actionDoc.data()! as Map<String, dynamic>;
        actions.add(Action.fromJson(actionData));
      }
    }

    return actions;
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final loggedInUser = ref.watch(authStateProvider).value;
  final firestoreService =
      FirestoreService(FirebaseFirestore.instance, loggedInUser);
  return firestoreService;
});
