import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../utils/app_colors.dart';

class CustomNavigationRail extends StatefulWidget {
  final PageController pageController;

  const CustomNavigationRail(this.pageController, {super.key});

  @override
  State<CustomNavigationRail> createState() => _CustomNavigationRailState();
}

class _CustomNavigationRailState extends State<CustomNavigationRail>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.h,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: const Offset(0, -1),
            blurRadius: 10.r,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          _bottomNavigationItem(0),
          _bottomNavigationItem(1),
          _bottomNavigationItem(2),
          _bottomNavigationItem(3),
        ],
      ),
    );
  }

  _bottomNavigationItem(int i) => Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
          onTap: () {
            _controller.forward(from: 0);
            _onItemTapped(i);
          },
          child: SizedBox(
            height: 50,
            width: 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/images/leaf.json',
                  controller: _controller,
                  height: 40.h,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..forward();
                  },
                ),
                AnimatedContainer(
                  height: 6.h,
                  width: 6.w,
                  margin: EdgeInsets.only(bottom: 6.h),
                  duration: const Duration(
                    milliseconds: 500,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6.h)),
                      color: _selectedIndex == i
                          ? Colors.white
                          : AppColors.primaryColor),
                ),
              ],
            ),
          ),
        ),
      );
}
