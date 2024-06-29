import 'package:flutter/material.dart';

bool isMobileScreen(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.width < 600;
  // final aspectRatio = size.width / size.height;
  // final isSmallDevice = size.shortestSide < 600;

  // return isSmallDevice && aspectRatio < 1.8;
}
