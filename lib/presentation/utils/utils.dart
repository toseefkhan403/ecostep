
import 'package:flutter/cupertino.dart';

bool isMobileScreen(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final aspectRatio = size.width / size.height;
  final isSmallDevice = size.shortestSide < 600;

  return isSmallDevice && aspectRatio < 1.8;
}
