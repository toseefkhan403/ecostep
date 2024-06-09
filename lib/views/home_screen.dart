import 'package:ecostep/views/pages/home_page.dart';
import 'package:ecostep/views/utils/app_colors.dart';
import 'package:ecostep/views/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

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
      _scrollController.jumpTo(_pageController.page! * MediaQuery.of(context).size.width);
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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
          child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/mountains.webp',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width * 3,
                ),
              ],
            ),
          ),
          PageView(
            controller: _pageController,
            // physics: const NeverScrollableScrollPhysics(),
            children: const [
              Center(child: Text('LeaderBoards')),
              HomePage(),
              Center(child: Text('Profile Page')),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavigationBar(_pageController),
          ),
        ],
      )),
    );
  }
}
