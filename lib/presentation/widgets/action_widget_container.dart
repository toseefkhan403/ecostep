import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/data/actions_repository.dart';
import 'package:ecostep/domain/date.dart';
import 'package:ecostep/presentation/controllers/action_refs_controller.dart';
import 'package:ecostep/presentation/controllers/week_state_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/action_widget.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/error_message_widget.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActionWidgetContainer extends ConsumerWidget {
  const ActionWidgetContainer({required this.actionRef, super.key});

  final dynamic actionRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const topMargin = 100.0;
    if (actionRef == null) {
      return actionNotFoundWidget(context, ref, topMargin);
    }

    final actionValue =
        ref.watch(actionProvider(actionRef as DocumentReference));

    return actionValue.when(
      data: (action) {
        if (action == null) {
          return actionNotFoundWidget(context, ref, topMargin);
        }
        return ActionWidget(action);
      },
      error: (e, st) => Padding(
        padding: const EdgeInsets.only(top: topMargin),
        child: Center(child: ErrorMessageWidget(e.toString())),
      ),
      loading: () => loadingIconAI(topMargin),
    );
  }

  Widget actionNotFoundWidget(
    BuildContext context,
    WidgetRef ref,
    double topMargin,
  ) {
    final actionsProvider = ref.read(actionRefsControllerProvider.notifier);
    final weekState = ref.watch(weekStateControllerProvider);
    if (weekState.selectedDate
        .isBefore(Date.today().subtract(const Duration(days: 1)))) {
      return const ActionWidget(null);
    }

    return Padding(
      padding: EdgeInsets.only(top: topMargin, left: 8, right: 8),
      child: Center(
        child: CircularElevatedButton(
          color: AppColors.secondaryColor,
          width: double.infinity,
          height: 60,
          blurRadius: 1,
          darkShadow: true,
          onPressed: () async {
            await actionsProvider.fetchCurrentUserActions(
              weekState.selectedWeek,
              generateMore: true,
            );
          },
          child: const Text(
            '''AI actions have not been generated for this week yet. Click to generate!''',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget actionExpiredWidget() => const Text('Action Expired');
}
