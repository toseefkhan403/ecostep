import 'package:ecostep/presentation/pages/leaderboard_page.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/custom_navigation_rail.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'home_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      _scrollController
          .jumpTo(_pageController.page! * MediaQuery.of(context).size.width);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = isMobileScreen(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: !isMobile
            ? webWidget()
            : Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Image.asset(
                      'assets/images/mountains.webp',
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width * 4,
                    ),
                  ),
                  PageView(
                    controller: _pageController,
                    // physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      HomePage(),
                      Center(child: Text('LeaderBoards')),
                      Center(child: Text('Marketplace')),
                      Center(child: Text('Profile Page')),
                    ],
                  ),
                  if (isMobile)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CustomBottomNavigationBar(_pageController),
                    ),
                ],
              ),
      ),
    );
  }

  Widget webWidget() => Stack(
        children: [
          Image.asset(
            'assets/images/mountains.png',
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const HomePage(),
                LeaderBoardPage(),
                Center(child: Text('Marketplace')),
                Center(child: Text('Profile Page')),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: CustomNavigationRail(_pageController),
          ),
        ],
      );
}
