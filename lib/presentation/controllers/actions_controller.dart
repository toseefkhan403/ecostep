import 'package:ecostep/application/firestore_service.dart';
import 'package:ecostep/application/gemini_service.dart';
import 'package:ecostep/domain/action.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODOadd better error handling
class ActionsController extends StateNotifier<List<Action>> {
  ActionsController(this.geminiService, this.firestoreService) : super([]);

  final GeminiService geminiService;
  final FirestoreService firestoreService;

  Future<void> currentWeekActions(List<DateTime> currentWeek) async {
    try {
      final actions = await firestoreService.fetchActions(currentWeek);
      if (actions.isEmpty) {
        final generatedActions = await geminiService.generateActions();
        state = generatedActions;
        await firestoreService.storeActions(generatedActions, currentWeek);
        return;
      }

      state = actions;
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

final actionsControllerProvider =
    StateNotifierProvider<ActionsController, List<Action>>((ref) {
  final geminiService = ref.read(geminiServiceProvider);
  final firestoreService = ref.read(firestoreServiceProvider);
  return ActionsController(geminiService, firestoreService);
});
