import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/domain/date.dart';
import 'package:ecostep/domain/user.dart';
import 'package:ecostep/presentation/controllers/action_refs_controller.dart';
import 'package:ecostep/presentation/controllers/week_state_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/action_widget_container.dart';
import 'package:ecostep/presentation/widgets/async_value_widget.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:ecostep/presentation/widgets/personalization_form_dialog.dart';
import 'package:ecostep/presentation/widgets/play_button_widget.dart';
import 'package:ecostep/presentation/widgets/week_widget.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final actionsValue = ref.watch(actionRefsControllerProvider);
    final userValue = ref.watch(firestoreUserProvider);
    final weekState = ref.watch(weekStateControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton:
          isMobileScreen(context) ? null : const PlayButtonWidget(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CenterContentPadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _dateHeading(),
                        const Spacer(),
                        _iconsRow(userValue),
                      ],
                    ),
                  ),
                  AsyncValueWidget(
                    value: userValue,
                    data: (user) => user.personalizationString != null
                        ? const SizedBox(height: 10)
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Semantics(
                              label: 'Open personalization form',
                              child: CircularElevatedButton(
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (context) {
                                      return const PersonalizationFormDialog();
                                    },
                                  );
                                },
                                width: double.infinity,
                                color: AppColors.backgroundColor,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    '''Your Gemini AI generated sustainable actions are not currently personalized. Click here to fill more information about your lifestyle to enable personalized actions.''',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    loading: () => const SizedBox(height: 10),
                  ),
                  WeekWidget(Date.today()),
                  AsyncValueWidget(
                    value: actionsValue,
                    topMargin: 100,
                    data: (actions) => ActionWidgetContainer(
                      actionRef: actions[weekState.selectedDate.toString()],
                    ),
                    loading: () => loadingIconAI(100),
                  ),
                  if (isMobileScreen(context)) const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconsRow(AsyncValue<User?> userValue) {
    return AsyncValueWidget(
      value: userValue,
      data: (user) => Row(
        children: [
          const LottieIconWidget(
            iconName: 'coin',
          ),
          Text(
            '${user.ecoBucksBalance}',
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          const LottieIconWidget(
            iconName: 'passion',
          ),
          Text(
            '${user.streak ?? 0}',
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
    );
  }

  Widget _dateHeading() => Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'Today',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 26,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: '\n${Date.today().getMonthFormattedDate()}',
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}
