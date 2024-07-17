import 'package:ecostep/application/firestore_service.dart';
import 'package:ecostep/application/gemini_service.dart';
import 'package:ecostep/domain/action.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActionsController extends StateNotifier<List<Action>> {
  ActionsController(this.geminiService, this.firestoreService) : super([]);

  final GeminiService geminiService;
  final FirestoreService firestoreService;

  Future<void> currentWeekActions(DateTime date) async {
    // TODOfetch actions from the users collection = each user should
    // have personalised actions
    final actions = await firestoreService.fetchActions(date);
    if (actions.isEmpty) {
      final generatedActions = await geminiService.generateActions();
      await firestoreService.storeActions(generatedActions);
      state = generatedActions;
      return;
    }

    state = actions;
  }
}

final actionsControllerProvider =
    StateNotifierProvider<ActionsController, List<Action>>((ref) {
  final geminiService = ref.read(geminiServiceProvider);
  final firestoreService = ref.read(firestoreServiceProvider);
  return ActionsController(geminiService, firestoreService);
});
