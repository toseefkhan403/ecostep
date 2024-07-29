import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieIconWidget extends StatefulWidget {
  const LottieIconWidget({
    required this.iconName,
    this.onTap,
    this.height = 50,
    this.autoPlay = false,
    this.repeat = false,
    super.key,
  });
  final String iconName;
  final double height;
  final bool autoPlay;
  final bool repeat;
  final void Function()? onTap;

  @override
  State<LottieIconWidget> createState() => _LottieIconWidgetState();
}

class _LottieIconWidgetState extends State<LottieIconWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.height,
      height: widget.height,
      child: GestureDetector(
        onTap: () {
          _controller
            ..reset()
            ..forward();
          widget.onTap?.call();
        },
        child: Lottie.asset(
          'assets/images/${widget.iconName}.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller.duration = composition.duration;
            if (widget.autoPlay) {
              _controller.forward();
            }
            if(widget.repeat) {
              _controller.repeat();
            }
          },
        ),
      ),
    );
  }
}
