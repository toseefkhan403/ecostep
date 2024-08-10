import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar(this.pageController, {super.key});
  final PageController pageController;

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    _selectedIndex = widget.pageController.page?.round() ?? 0;
    super.initState();
  }

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
      height: 60,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, -1),
            blurRadius: 10,
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

  Widget _bottomNavigationItem(int i) => Padding(
        padding: const EdgeInsets.all(8),
        child: Semantics(
          label: labelFromNavigationIndex(i),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LottieIconWidget(
                iconName: iconFromNavigationIndex(i),
                onTap: () => _onItemTapped(i),
                height: 35,
              ),
              AnimatedContainer(
                height: 6,
                width: 6,
                duration: const Duration(
                  milliseconds: 500,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  color: _selectedIndex == i
                      ? AppColors.primaryColor
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
}
