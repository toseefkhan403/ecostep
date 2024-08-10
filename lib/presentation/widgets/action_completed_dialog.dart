import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/async_value_widget.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionCompletedDialog extends StatefulWidget {
  const ActionCompletedDialog(
    this.balance,
    this.streak,
    this.actionTitle, {
    super.key,
  });

  final int balance;
  final int streak;
  final String actionTitle;

  @override
  State<ActionCompletedDialog> createState() => _ActionCompletedDialogState();
}

class _ActionCompletedDialogState extends State<ActionCompletedDialog> {
  bool showNewBalance = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Durations.medium1, () {
        setState(() {
          showNewBalance = true;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = !isMobileScreen(context)
        ? MediaQuery.of(context).size.width * 0.5
        : 300.0;

    return CenterContentPadding(
      child: AlertDialog(
        title: const Text(
          'Action Completed Successfully!',
          style: TextStyle(
            fontSize: 26,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final userValue = ref.watch(firestoreUserProvider);

                  return AsyncValueWidget(
                    value: userValue,
                    data: (user) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LottieIconWidget(
                              iconName: 'coin',
                              height: 80,
                            ),
                            AnimatedFlipCounter(
                              duration: const Duration(seconds: 1),
                              value: showNewBalance
                                  ? user.ecoBucksBalance
                                  : widget.balance,
                              textStyle: const TextStyle(
                                color: AppColors.textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LottieIconWidget(
                              iconName: 'passion',
                              height: 80,
                            ),
                            AnimatedFlipCounter(
                              duration: const Duration(milliseconds: 500),
                              value: showNewBalance
                                  ? user.streak ?? 1
                                  : widget.streak,
                              textStyle: const TextStyle(
                                color: AppColors.textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 15),
                child: Text(
                  '''You have completed and verified your action successfully. Share the good news with your friends!''',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Semantics(
                label: 'Share your action on social media',
                child: FilledButton(
                  onPressed: () async {
                    final shareMessage =
                        "I just completed a sustainable action and got rewarded for it! GreenLoop gives you rewards for completing daily sustainable actions, which you can use to buy/sell recycled goods on their marketplace! It's awesome! My action was: ${widget.actionTitle}";
                    const url = 'https://greenloop-a67da.web.app/';
                    await launchUrl(
                      Uri.parse(
                        'https://x.com/intent/tweet?text=$shareMessage&url=$url',
                      ),
                    );
                  },
                  child: const Text('Share on Twitter/X'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
