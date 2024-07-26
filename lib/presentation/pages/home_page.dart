import 'package:ecostep/application/firebase_auth_service.dart';
import 'package:ecostep/domain/action.dart';
import 'package:ecostep/presentation/controllers/actions_controller.dart';
import 'package:ecostep/presentation/controllers/week_widget_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/date_utils.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/async_value_widget.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:ecostep/presentation/widgets/verify_image_dialog.dart';
import 'package:ecostep/presentation/widgets/week_widget.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neopop/neopop.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  DateTime today = DateTime.now();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref
          .read(actionsControllerProvider.notifier)
          .fetchCurrentUserActions(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final actionsValue = ref.watch(actionsControllerProvider);
    final weekState = ref.watch(weekWidgetControllerProvider);

    final width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: !isMobileScreen(context) ? width * 0.25 : 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dateHeading(),
                      const Spacer(),
                      _iconButton('passion'),
                      SizedBox(width: 8.w),
                      _iconButton('recycle'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 30.h),
                  child: CircularElevatedButton(
                    onPressed: () {},
                    width: double.infinity,
                    color: AppColors.backgroundColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.w),
                      child: const Text(
                        '''Your AI generated sustainable actions are not currently personalized. Click here to fill more information about your lifestyle to enable personalized actions.''',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                WeekWidget(today),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: AsyncValueWidget(
                    value: actionsValue,
                    data: (actions) => actionWidget(
                        actions[getFormattedDateForDb(weekState.selectedDate)]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(String iconName) {
    return Consumer(
      builder: (context, ref, child) {
        return Row(
          children: [
            LottieIconWidget(
              iconName: iconName,
              onTap: () => ref.read(firebaseAuthServiceProvider).signOut(),
            ),
            Text(
              '4',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dateHeading() => Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Today',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 26.sp,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: '\n${getFormattedDate(today)}',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget actionNotFoundWidget() {
    final actionsProvider = ref.read(actionsControllerProvider.notifier);
    final weekState = ref.watch(weekWidgetControllerProvider);

    return Center(
        child: TextButton(
          onPressed: () async {
            final success = await actionsProvider
                .generateActionsForWeek(weekState.selectedWeek);
            if (success) {
              await ref
                  .read(actionsControllerProvider.notifier)
                  .fetchCurrentUserActions();
            } else {
              showSnackbar(
                context,
                'Our AI is overloaded with work right now! Please try again later!',
              );
            }
          },
          child: const Text(
            'AI actions have not been generated for this week yet. Click here to generate',
          ),
        ),
      );
  }

  Widget actionWidget(Action? action) {
    if (action == null) {
      return actionNotFoundWidget();
    }
    // TODOfetch and set isVerified in db
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(22.r)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22.r),
                topRight: Radius.circular(22.r),
              ),
            ),
            child: NeoPopShimmer(
              shimmerColor: Colors.white54,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'Action of the day'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(6.w),
            child: Text(
              action.action,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          levelBar(
            difficulty: action.difficulty,
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              getTimeUntilEod(),
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.h),
            child: Text(
              'Description: ${action.description}',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.accentColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(22.r),
                bottomRight: Radius.circular(22.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          width: 1.2.w,
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
                      child: Text(
                        'Verify',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: Text(
                      'Impact',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          width: 1.2.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Text(
                        'Modify',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: levelColor,
        borderRadius: BorderRadius.all(Radius.circular(18.r)),
      ),
      child: Row(
        children: [
          Text(
            difficulty,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          const LottieIconWidget(iconName: 'coin'),
          Text(
            '4',
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
