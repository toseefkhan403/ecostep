import 'package:flutter/material.dart';

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

void showSnackbar(BuildContext context, String title) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
      ),
    );
