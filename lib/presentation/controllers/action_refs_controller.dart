// ignore_for_file: avoid_manual_providers_as_generated_provider_dependency
import 'package:ecostep/data/actions_repository.dart';
import 'package:ecostep/data/gemini_repository.dart';
import 'package:ecostep/domain/date.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'action_refs_controller.g.dart';

@Riverpod(keepAlive: true)
class ActionRefsController extends _$ActionRefsController {
  // returns Map<String, DocumentRef>
  @override
  Future<Map<String, dynamic>> build() async =>
      fetchCurrentUserActions(Date.presentWeek());

  Future<Map<String, dynamic>> fetchCurrentUserActions(
    List<Date> week, {
    bool generateDirectly = false,
  }) async {
    state = const AsyncLoading();
    var actions = <String, dynamic>{};
    final actionProvider = ref.read(actionRepositoryProvider);

    try {
      if (!generateDirectly) {
        actions = await actionProvider.fetchUserActions();
      }
      if (actions.values.isEmpty || actions[week.first.toString()] == null) {
        await _generateActionsForWeek(week);
        actions = await actionProvider.fetchUserActions();
      }
      state = AsyncData(actions);
      return actions;
    } catch (e, st) {
      state = AsyncError(e, st);
      debugPrint('Error fetching user actions: $e');
    }

    return {};
  }

  Future<void> _generateActionsForWeek(List<Date> week) async {
    try {
      final generatedActions =
          await ref.read(geminiServiceProvider).generateActions();
      await ref
          .read(actionRepositoryProvider)
          .storeActions(generatedActions, week);
    } catch (e) {
      debugPrint('Error generating actions for the week: $e');
    }
  }
}
