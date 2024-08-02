import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/domain/date.dart';
import 'package:ecostep/presentation/controllers/action_refs_controller.dart';
import 'package:ecostep/presentation/controllers/week_state_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/action_widget_container.dart';
import 'package:ecostep/presentation/widgets/async_value_widget.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/error_message_widget.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
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
    final weekState = ref.watch(weekStateControllerProvider);

    return SingleChildScrollView(
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
                      _iconsRow(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: CircularElevatedButton(
                    onPressed: () {},
                    width: double.infinity,
                    color: AppColors.backgroundColor,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '''Your AI generated sustainable actions are not currently personalized. Click here to fill more information about your lifestyle to enable personalized actions.''',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconsRow() {
    final userValue = ref.watch(firestoreUserProvider);
    return userValue.when(
      data: (user) => Row(
        children: [
          const LottieIconWidget(
            iconName: 'coin',
          ),
          Text(
            '${user?.ecoBucksBalance ?? 100}',
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
            '${user?.streak ?? 0}',
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      error: (e, st) => Center(child: ErrorMessageWidget(e.toString())),
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
