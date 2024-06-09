import 'package:ecostep/views/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final PageController pageController;

  const CustomBottomNavigationBar(this.pageController, {super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 1;

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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home,
                    color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
                onPressed: () => _onItemTapped(0),
              ),
              SizedBox(width: 50), // Space for the middle item
              IconButton(
                icon: Icon(Icons.person,
                    color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
                onPressed: () => _onItemTapped(2),
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          left: MediaQuery.of(context).size.width / 2 - 30,
          child: GestureDetector(
            onTap: () => _onItemTapped(1),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.r,
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
