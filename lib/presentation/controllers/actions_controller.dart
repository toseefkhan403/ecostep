import 'package:ecostep/application/firestore_service.dart';
import 'package:ecostep/application/gemini_service.dart';
import 'package:ecostep/domain/action.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'actions_controller.g.dart';

@Riverpod(keepAlive: true)
class ActionsController extends _$ActionsController {
  @override
  Future<Map<String, Action>> build() async => fetchCurrentUserActions();

  Future<Map<String, Action>> fetchCurrentUserActions() async {
    state = const AsyncLoading();
    try {
      final actions = await ref.read(firestoreServiceProvider).fetchActions();
      state = AsyncData(actions);
      return actions;
    } catch (e, st) {
      state = AsyncError(e, st);
      debugPrint(e.toString());
    }

    return {};
  }

  Future<bool> generateActionsForWeek(List<DateTime> week) async {
    try {
      final generatedActions =
          await ref.read(geminiServiceProvider).generateActions();
      await ref
          .read(firestoreServiceProvider)
          .storeActions(generatedActions, week);
      return true;
    } catch (e) {
      debugPrint(e.toString());
    }

    return false;
  }
}
