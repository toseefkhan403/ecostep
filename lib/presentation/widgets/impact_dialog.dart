import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';

class ImpactDialog extends StatelessWidget {
  const ImpactDialog(this.impact, this.impactIfNotDone, {super.key});

  final String impact;
  final String impactIfNotDone;

  @override
  Widget build(BuildContext context) {
    final dialogWidth = !isMobileScreen(context)
        ? MediaQuery.of(context).size.width * 0.5
        : 300.0;

    return CenterContentPadding(
      child: AlertDialog(
        insetPadding: isMobileScreen(context)
            ? const EdgeInsets.all(10)
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        title: const Text(
          'Action Impact',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _impactWidget(true),
              const SizedBox(width: 10),
              _impactWidget(false),
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

  Widget _impactWidget(bool positiveImpact) => Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LottieIconWidget(
              iconName: positiveImpact ? 'right-decision' : 'wrong-decision',
              height: 100,
              autoPlay: true,
            ),
            Text(
              positiveImpact ? impact : impactIfNotDone,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
