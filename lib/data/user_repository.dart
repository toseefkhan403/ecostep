// ignore_for_file: avoid_manual_providers_as_generated_provider_dependency
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/application/firebase_auth_service.dart';
import 'package:ecostep/application/firestore_service.dart';
import 'package:ecostep/domain/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth_user;
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_repository.g.dart';

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

  Stream<User?> firestoreUser() {
    if (currentUser?.uid == null) {
      return Stream.value(null);
    }
    debugPrint('currentUser: ${currentUser?.uid}');

    final userDocRef =
        firestoreService.firestore.collection('users').doc(currentUser?.uid);

    return userDocRef.snapshots().map((snapshot) {
      if (snapshot.data() == null) return null;
      return User.fromJson(snapshot.data()!);
    });
  }

  void addEcoBucks(int reward) {
    final userDocRef =
        firestoreService.firestore.collection('users').doc(currentUser?.uid);
    firestoreService.updateDocument(
      userDocRef,
      {'ecoBucksBalance': FieldValue.increment(reward)},
    );
  }
}

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final loggedInUser = ref.watch(authStateProvider).value;
  return UserRepository(firestoreService, loggedInUser);
}

@riverpod
Stream<User?> firestoreUser(FirestoreUserRef ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.firestoreUser();
}
