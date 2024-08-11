import 'package:ecostep/application/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_repository.g.dart';

class ConfigRepository {
  ConfigRepository(this.firestoreService);

  final FirestoreService firestoreService;

  Future<bool> showPlayButton() async {
    try {
      final configRef =
          firestoreService.firestore.collection('config').doc('playStore');
      final querySnapshot = await configRef.get();

      if (querySnapshot.exists) {
        final json = querySnapshot.data();
        return json?['showPlayButton'] as bool? ?? false;
      }
    } catch (e) {
      debugPrint('Error fetching play button config: $e');
    }
    return false;
  }
}

@riverpod
ConfigRepository configRepository(ConfigRepositoryRef ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ConfigRepository(firestoreService);
}

@riverpod
Future<bool> showPlayButton(ShowPlayButtonRef ref) {
  final configRepository = ref.watch(configRepositoryProvider);
  return configRepository.showPlayButton();
}
