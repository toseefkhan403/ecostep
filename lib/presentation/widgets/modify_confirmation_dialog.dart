import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/domain/date.dart';
import 'package:ecostep/presentation/controllers/action_refs_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class ModifyConfirmationDialog extends StatelessWidget {
  const ModifyConfirmationDialog(this.ecoBucksBalance, {super.key});

  final int ecoBucksBalance;

  @override
  Widget build(BuildContext context) {
    final dialogWidth = !isMobileScreen(context)
        ? MediaQuery.of(context).size.width * 0.5
        : 300.0;
    const fees = 50;

    return CenterContentPadding(
      child: AlertDialog(
        title: const Text(
          "Modify Today's Action",
          style: TextStyle(
            color: AppColors.primaryColor,
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
                    '$fees',
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
            builder: (c, ref, child) => FilledButton(
              onPressed: () async {
                if (ecoBucksBalance < fees) {
                  showToast(
                    ref,
                    'Insufficient balance!',
                    type: ToastificationType.error,
                  );
                  return;
                }

                final success = await ref
                    .read(userRepositoryProvider)
                    .modifyAction(Date.today(), fees);
                if (success) {
                  await ref
                      .read(actionRefsControllerProvider.notifier)
                      .fetchCurrentUserActions(
                        Date.presentWeek(),
                      );
                  showToast(
                    ref,
                    'Action modified successfully!',
                  );
                } else {
                  showToast(
                    ref,
                    "Could not modify today's action. Please try again later!",
                  );
                }
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('Proceed'),
            ),
          ),
        ],
      ),
    );
  }
}
