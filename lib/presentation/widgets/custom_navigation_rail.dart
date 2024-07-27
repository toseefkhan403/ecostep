import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';


class CustomNavigationRail extends StatefulWidget {
  const CustomNavigationRail(this.pageController, {super.key});
  final PageController pageController;

  @override
  State<CustomNavigationRail> createState() => _CustomNavigationRailState();
}

class _CustomNavigationRailState extends State<CustomNavigationRail>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset:  Offset(0, -1),
            blurRadius: 10,
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

  Widget _bottomNavigationItem(int i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LottieIconWidget(
              iconName: iconFromNavigationIndex(i),
              onTap: () => _onItemTapped(i),
            ),
            AnimatedContainer(
              height: 6,
              width: 6,
              duration: const Duration(
                milliseconds: 500,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                color:
                    _selectedIndex == i ? Colors.white : AppColors.primaryColor,
              ),
            ),
          ],
        ),
      );
}
