import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/application/firebase_auth_service.dart';
import 'package:ecostep/application/firestore_service.dart';
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth_user;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_string/random_string.dart';

class MarketPlaceRepository {
  MarketPlaceRepository(this.firestoreService, this.currentUser);

  final FirestoreService firestoreService;
  final auth_user.User? currentUser;
  Stream<List<MarketplaceItem>> fetchMarketplaceItems() {
    final marketplaceref =
        firestoreService.firestore.collection('marketplaceItems');

    return marketplaceref.snapshots().map((querySnapshot) {
      final items = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return MarketplaceItem.fromJson(data);
      }).toList();
      return items;
    });
  }

  Future<void> sendPurchaseRequest({
    required MarketplaceItem item,
    required String buyerprice,
  }) async {
    if (currentUser == null) {
      throw StateError('No user is currently logged in');
    }

    final currentUserUid = currentUser!.uid;
    final purchaseRequestId = randomAlphaNumeric(12);
    final buyerRef =
        firestoreService.firestore.collection('users').doc(currentUserUid);
    final DocumentReference itemRef = firestoreService.firestore
        .collection('marketplaceItems')
        .doc(item.docid);
    final sellerRef = item.sellingUser as DocumentReference;
    final timestamp = Timestamp.now();

    final purchaseRequestData = <String, dynamic>{
      'buyerId': buyerRef,
      'item': itemRef,
      'sellerId': sellerRef,
      'buyerPrice': buyerprice,
      'timestamp': timestamp,
      'sellerConfirm': false,
      'buyerConfirm': false,
    };

    try {
      final ref = firestoreService.firestore
          .collection('purchaseRequests')
          .doc(purchaseRequestId);
      await firestoreService.setDocument(ref, purchaseRequestData);

      await sellerRef.update(
        {
          'buyerRequests': FieldValue.arrayUnion([ref]),
        },
      );


    } catch (e) {
      debugPrint('Error sending buyer request: $e');

      rethrow;
    }
    try {
      final ref = firestoreService.firestore
          .collection('purchaseRequests')
          .doc(purchaseRequestId);
      await firestoreService.setDocument(ref, purchaseRequestData);

      await buyerRef.update(
        {
          'sellerRequests': FieldValue.arrayUnion([ref]),
        },
      );

  
    } catch (e) {
      debugPrint('Error sending buyer request: $e');

      rethrow;
    }
  }
}

final marketplaceRepositoryProvider = Provider<MarketPlaceRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final loggedInUser = ref.watch(authStateProvider).value;
  return MarketPlaceRepository(firestoreService, loggedInUser);
});
