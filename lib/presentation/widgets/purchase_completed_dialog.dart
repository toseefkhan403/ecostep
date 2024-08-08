import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';

class PurchaseCompletedDialog extends StatelessWidget {
  const PurchaseCompletedDialog({required this.isSuccess, super.key});
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final dialogWidth = !isMobileScreen(context)
        ? MediaQuery.of(context).size.width * 0.5
        : 300.0;

    return CenterContentPadding(
      child: AlertDialog(
        title: Text(
          isSuccess ? 'Purchase Completed' : 'Purchase Failed',
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LottieIconWidget(
                iconName: isSuccess ? 'right-decision' : 'wrong-decision',
                height: 150,
                repeat: true,
              ),
              Text(
                '''Your Purchase has been ${isSuccess ? 'completed sucessfully!' : 'failed. Please try again later.'}''',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
