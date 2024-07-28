import 'package:ecostep/application/extensions.dart';
import 'package:ecostep/domain/action.dart';
import 'package:ecostep/domain/date.dart';
import 'package:ecostep/presentation/controllers/week_state_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/expired_overlay.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:ecostep/presentation/widgets/verify_image_dialog.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neopop/neopop.dart';

class ActionWidget extends ConsumerStatefulWidget {
  const ActionWidget(this.action, {super.key});

  final Action? action;

  @override
  ConsumerState<ActionWidget> createState() => _ActionWidgetState();
}

class _ActionWidgetState extends ConsumerState<ActionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weekState = ref.watch(weekStateControllerProvider);
    final action = widget.action;
    // TODOfetch and set isVerified in db
    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(22)),
          child: ExpiredOverlay(
            isExpired: weekState.selectedDate
                .isBefore(Date.today().subtract(const Duration(days: 1))),
            child: Container(
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
                    padding: const EdgeInsets.all(8),
                    child: AnimatedSwitcher(
                      duration: Durations.short4,
                      child: Text(
                        action?.action ?? 'Sustainable Action',
                        key: ValueKey(action?.action),
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  levelBar(
                    difficulty:
                        action?.difficulty.capitalizeFirstLetter() ?? 'Easy',
                  ),
                  if (weekState.selectedDate == Date.today())
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
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                    child: Text(
                      action?.description ?? 'Sustainable action description',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  actionRow(context, action),
                ],
              ),
            ),
          ),
        ),
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
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          Text(
            coinsFromDifficulty(difficulty.toLowerCase()).toString(),
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

  Widget actionRow(BuildContext context, Action? action) => Container(
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
                    if (action == null) return;

                    showDialog<void>(
                      context: context,
                      builder: (c) => VerifyImageDialog(action),
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
}
