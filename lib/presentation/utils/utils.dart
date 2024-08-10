import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/application/audio_player_service.dart';
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

bool isMobileScreen(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.width < 800;
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
      return 'eco-earth';
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

String labelFromNavigationIndex(int i) {
  switch (i) {
    case 0:
      return 'Home';
    case 1:
      return 'Leaderboard';
    case 2:
      return 'Marketplace';
    case 3:
      return 'Profile';
    default:
      return 'Home';
  }
}

void showToast(
  WidgetRef ref,
  String title, {
  ToastificationType type = ToastificationType.info,
}) {
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
  ref.read(audioPlayerServiceProvider).playSound('error', extension: 'mp3');
}

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
  return Padding(
    padding: EdgeInsets.only(top: topMargin),
    child: const Center(
      child: LottieIconWidget(
        iconName: 'artificial-intelligence (1)',
        height: 100,
        repeat: true,
      ),
    ),
  );
}

List<MarketplaceItem> getUserSellerItems(
  List<MarketplaceItem> items,
  String? currentUserUid,
) {
  return items.where((item) {
    final sellingUserId = (item.sellingUser as DocumentReference).id;
    return sellingUserId == currentUserUid;
  }).toList();
}

String formatMonths(int noOfMonths) {
  if (noOfMonths <= 0) return '0 months';

  final years = noOfMonths ~/ 12;
  final months = noOfMonths % 12;

  final yearsString = years > 0 ? '$years year${years > 1 ? 's' : ''}' : '';
  final monthsString =
      months > 0 ? '$months month${months > 1 ? 's' : ''}' : '';

  if (yearsString.isNotEmpty && monthsString.isNotEmpty) {
    return '$yearsString $monthsString';
  } else if (yearsString.isNotEmpty) {
    return yearsString;
  } else {
    return monthsString;
  }
}
