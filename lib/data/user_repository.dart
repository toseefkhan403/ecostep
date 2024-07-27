import 'package:ecostep/application/firebase_auth_service.dart';
import 'package:ecostep/application/firestore_service.dart';
import 'package:ecostep/domain/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth_user;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRepository {
  UserRepository(this.firestoreService, this.currentUser);

  final FirestoreService firestoreService;
  final auth_user.User? currentUser;

  Future<void> createUserIfDoesntExist(User user) async {
    if (await doesUserExist(user.id)) return;

    final userDocRef =
        firestoreService.firestore.collection('users').doc(user.id);
    await firestoreService.setDocument(userDocRef, user.toJson());
  }

  Future<bool> doesUserExist(String? uid) async {
    final userDocRef = firestoreService.firestore.collection('users').doc(uid);
    final querySnapshot = await firestoreService.getDocument(userDocRef);
    return querySnapshot.exists;
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final loggedInUser = ref.watch(authStateProvider).value;
  return UserRepository(firestoreService, loggedInUser);
});
