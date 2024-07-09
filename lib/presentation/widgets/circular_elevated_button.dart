import 'package:ecostep/presentation/utils/utils.dart';
import 'package:flutter/material.dart';

class CircularElevatedButton extends StatelessWidget {
  const CircularElevatedButton({
    required this.onPressed,
    required this.child,
    this.color = Colors.white,
    this.width = 150.0,
    this.height,
    this.borderRadius = 22.0,
    this.blurRadius = 5.0,
    this.elevation = 5.0,
    this.darkShadow = false,
    super.key,
  });

  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final double width;
  final double? height;
  final double borderRadius;
  final double blurRadius;
  final double elevation;
  final bool darkShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: roundedContainerDecoration(
        color: color,
        elevation: elevation,
        borderRadius: borderRadius,
        blurRadius: blurRadius,
        darkShadow: darkShadow,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0, // Elevation handled by BoxShadow
        ),
        child: Center(child: child),
      ),
    );
  }
}
