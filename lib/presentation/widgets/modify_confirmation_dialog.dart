import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModifyConfirmationDialog extends StatelessWidget {
  const ModifyConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final dialogWidth = !isMobileScreen(context)
        ? MediaQuery.of(context).size.width * 0.5
        : 300.0;

    return CenterContentPadding(
      child: AlertDialog(
        title: const Text(
          "Modify Today's Action",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                """Unsure about today's action? You can change it for a price of: """,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LottieIconWidget(
                    iconName: 'coin',
                  ),
                  Text(
                    '50',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) => FilledButton(
              onPressed: () {
                // TODOmodify action - can only modify today's action
                // change ref in user's collection - fetchRefs again
                // also cant modify if action is verified already
                // TODOadd 7 days limit to action verification - add Toasts
                // ref.read(userRepositoryProvider).modifyAction();
              },
              child: const Text('Proceed'),
            ),
          ),
        ],
      ),
    );
  }
}
