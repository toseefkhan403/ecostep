import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../utils/app_colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final PageController pageController;

  const CustomBottomNavigationBar(this.pageController, {super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
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
      height: 60.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: const Offset(0, -1),
            blurRadius: 10.r,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomNavigationItem(0),
          _bottomNavigationItem(1),
          _bottomNavigationItem(2),
          _bottomNavigationItem(3),
        ],
      ),
    );
  }

  _bottomNavigationItem(int i) => InkWell(
        onTap: () {
          _controller.forward(from: 0);
          _onItemTapped(i);
        },
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
              duration: const Duration(milliseconds: 500,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6.h)),
                color: _selectedIndex == i
                    ? AppColors.primaryColor
                    : Colors.white,
              ),
            ),
          ],
        ),
      );
}
