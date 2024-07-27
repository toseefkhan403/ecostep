import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/data/actions_repository.dart';
import 'package:ecostep/domain/action.dart';
import 'package:ecostep/domain/date.dart';
import 'package:ecostep/presentation/controllers/action_refs_controller.dart';
import 'package:ecostep/presentation/controllers/week_state_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/error_message_widget.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:ecostep/presentation/widgets/verify_image_dialog.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neopop/neopop.dart';

class ActionWidget extends ConsumerWidget {
  const ActionWidget({required this.actionRef, super.key});

  final dynamic actionRef;
  // ignore: avoid_field_initializers_in_const_classes
  final topMargin = 100.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (actionRef == null) {
      return actionNotFoundWidget(ref, context);
    }

    final actionValue =
        ref.watch(actionProvider(actionRef as DocumentReference));

    return actionValue.when(
      data: (action) {
        if (action == null) {
          return actionNotFoundWidget(ref, context);
        }
        return actionWidget(action, context);
      },
      error: (e, st) => Padding(
        padding: EdgeInsets.only(top: topMargin),
        child: Center(child: ErrorMessageWidget(e.toString())),
      ),
      loading: () {
        return Padding(
          padding: EdgeInsets.only(top: topMargin),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget actionWidget(Action action, BuildContext context) {
    // TODOfetch and set isVerified in db
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: NeoPopShimmer(
              shimmerColor: Colors.white54,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Action of the day'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              action.action,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          levelBar(
            difficulty: action.difficulty,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              Date.getTimeUntilEod(),
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Description: ${action.description}',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actionRow(context),
        ],
      ),
    );
  }

  Widget levelBar({required String difficulty}) {
    var levelColor = AppColors.accentColor;
    if (difficulty.toLowerCase() == 'moderate') {
      levelColor = AppColors.secondaryColor;
    } else if (difficulty.toLowerCase() == 'hard') {
      levelColor = Colors.amber;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: levelColor,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),
      child: Row(
        children: [
          Text(
            difficulty,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          const LottieIconWidget(iconName: 'coin'),
          const Text(
            '4',
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget actionNotFoundWidget(WidgetRef ref, BuildContext context) {
    final actionsProvider = ref.read(actionRefsControllerProvider.notifier);
    final weekState = ref.watch(weekStateControllerProvider);
    if (weekState.selectedDate
        .isBefore(Date.today().subtract(const Duration(days: 1)))) {
      return actionExpiredWidget();
    }

    return Padding(
      padding: EdgeInsets.only(top: topMargin),
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
              generateDirectly: true,
            );
          },
          child: const Text(
            '''AI actions have not been generated for this week yet. Click to generate!''',
          ),
        ),
      ),
    );
  }

  Widget actionRow(BuildContext context) => Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.accentColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      width: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (c) => const VerifyImageDialog(),
                    );
                  },
                  child: const Text(
                    'Verify',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {},
                child: const Text(
                  'Impact',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      width: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: () {},
                  child: const Text(
                    'Modify',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget actionExpiredWidget() => const Text('Action Expired');
}
