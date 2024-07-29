import 'package:ecostep/presentation/utils/utils.dart';
import 'package:flutter/material.dart';

class CenterContentPadding extends StatelessWidget {
  const CenterContentPadding({this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: !isMobileScreen(context) ? width * 0.25 + 30 : 10,
        vertical: 10,
      ),
      child: child,
    );
  }
}
