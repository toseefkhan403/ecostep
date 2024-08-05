import 'package:flutter/material.dart';

class ExpiredOverlay extends StatelessWidget {
  const ExpiredOverlay({
    required this.child,
    required this.isExpired,
    this.expiredMessage,
    this.messageColor,
    super.key,
  });
  final Widget child;
  final bool isExpired;
  final String? expiredMessage;
  final Color? messageColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: isExpired,
          child: child,
        ),
        if (isExpired)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.grey.withOpacity(0.8),
              child: Center(
                child: Transform.rotate(
                  angle: -30 * 3.1415926535 / 180,
                  child: Text(
                    expiredMessage ?? 'EXPIRED',
                    style: TextStyle(
                      fontSize: 50,
                      color: messageColor ?? Colors.black45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
