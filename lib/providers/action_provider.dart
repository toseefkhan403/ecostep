import 'dart:typed_data';

import 'package:ecostep/domain/action.dart';
import 'package:ecostep/services/api_services.dart';
import 'package:ecostep/services/firebase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final actionsProvider =
    StateNotifierProvider<ActionsNotifier, List<Action>>((ref) {
  return ActionsNotifier();
});

class ActionsNotifier extends StateNotifier<List<Action>> {
  ActionsNotifier() : super([]) {
    _initializeActions();
  }

  final FirebaseService _firebaseService = FirebaseService();
  final ApiService _apiService = ApiService();

  Future<void> _initializeActions() async {
    final actions = await _firebaseService.fetchActions();
    if (actions.isEmpty) {
      final generatedActions = await _apiService.generateActions();
      await _firebaseService.storeActions(generatedActions);
      state = generatedActions;
    } else {
      state = actions;
    }
  }

  Future<void> fetchActions() async {
    state = await _firebaseService.fetchActions();
  }

  Future<int> verifyImage(Uint8List imageBytes) async {
    return await _apiService.verifyImage(imageBytes);
  }
}
