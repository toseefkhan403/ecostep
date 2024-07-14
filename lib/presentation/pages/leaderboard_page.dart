import 'package:ecostep/domain/user.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({super.key});

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  final List<User> dummyRecentUsers = [];
  final List<User> dummyImpactUsers = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 10; i++) {
      dummyRecentUsers.add(
        User(
          id: '$i',
          ecoBucksBalance: i * 10,
          personalization: false,
          joinedOn: DateTime.now(),
        ),
      );

      dummyImpactUsers.add(
        User(
          id: '$i',
          ecoBucksBalance: i * 10,
          personalization: false,
          joinedOn: DateTime.now(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: !isMobileScreen(context) ? width * 0.25 : 10,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Text(
              'Leaderboard',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 26.sp,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buttonRow(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20.h),
                  padding: EdgeInsets.all(20.w),
                  decoration:
                      roundedContainerDecoration(color: AppColors.accentColor),
                  child: ListView.builder(
                    itemCount: dummyRecentUsers.length,
                    itemBuilder: (context, index) =>
                        userCard(dummyRecentUsers[index], index),
                  ),
                ),
                ListView.builder(
                  itemCount: dummyImpactUsers.length,
                  itemBuilder: (context, index) =>
                      userCard(dummyImpactUsers[index], index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buttonRow() => Padding(
        padding: EdgeInsets.all(8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: CircularElevatedButton(
                color: _selectedIndex == 0
                    ? AppColors.secondaryColor
                    : AppColors.backgroundColor,
                blurRadius: _selectedIndex == 0 ? 1 : 5,
                darkShadow: _selectedIndex == 0,
                onPressed: () => _onItemTapped(0),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  child: const Text(
                    'Most Recent',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 30.w,
            ),
            Expanded(
              child: CircularElevatedButton(
                color: _selectedIndex == 1
                    ? AppColors.secondaryColor
                    : AppColors.backgroundColor,
                onPressed: () => _onItemTapped(1),
                blurRadius: _selectedIndex == 1 ? 1 : 5,
                darkShadow: _selectedIndex == 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  child: const Text(
                    'Most Impact',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget userCard(User dummyRecentUser, int index) => Container(
        padding: EdgeInsets.all(20.w),
        margin: EdgeInsets.symmetric(vertical: 20.h),
        decoration: roundedContainerDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: CircleAvatar(
                    radius: 25.r,
                  ),
                ),
                Text(
                  '${dummyRecentUser.name}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'Impact Score: ${dummyRecentUser.impactScore}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Joined On: ${DateFormat('MMM yy').format(dummyRecentUser.joinedOn)}",
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
}
