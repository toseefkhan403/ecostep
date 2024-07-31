import 'dart:math';

import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

bool isMobileScreen(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.width < 600;
  // final aspectRatio = size.width / size.height;
  // final isSmallDevice = size.shortestSide < 600;

  // return isSmallDevice && aspectRatio < 1.8;
}

BoxDecoration roundedContainerDecoration({
  Color color = Colors.white,
  double borderRadius = 22.0,
  double elevation = 5.0,
  double blurRadius = 5.0,
  bool darkShadow = false,
}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(darkShadow ? 0.7 : 0.4),
          spreadRadius: 1,
          blurRadius: blurRadius,
          offset: Offset(0, elevation),
        ),
      ],
      border: Border.all(),
    );

String iconFromNavigationIndex(int i) {
  switch (i) {
    case 0:
      return 'home';
    case 1:
      return 'podium';
    case 2:
      return 'stalls';
    case 3:
      return 'boy';
    default:
      return 'recycle';
  }
}

void showToast(
  String title, {
  ToastificationType type = ToastificationType.info,
}) =>
    toastification.show(
      title: Text(
        title,
      ),
      type: type,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: const Duration(seconds: 5),
      primaryColor: AppColors.accentColor,
      foregroundColor: Colors.black,
      alignment: Alignment.bottomCenter,
      animationDuration: const Duration(milliseconds: 300),
      showProgressBar: false,
      animationBuilder: (context, animation, alignment, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );

int coinsFromDifficulty(String difficulty) {
  if (difficulty == 'easy') {
    return 100;
  }
  if (difficulty == 'hard') {
    return 300;
  }

  return 200;
}

Widget loadingIconAI(double topMargin) {
  final icons = [
    'artificial-intelligence',
    'artificial-intelligence (1)',
  ];
  return Padding(
    padding: EdgeInsets.only(top: topMargin),
    child: Center(
      child: LottieIconWidget(
        iconName: icons[Random().nextInt(icons.length)],
        height: 100,
        repeat: true,
      ),
    ),
  );
}
