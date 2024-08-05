import 'package:ecostep/application/audio_player_service.dart';
import 'package:ecostep/presentation/pages/home_page.dart';
import 'package:ecostep/presentation/pages/leaderboard_page.dart';
import 'package:ecostep/presentation/pages/market_place_screen.dart';
import 'package:ecostep/presentation/pages/profile_page.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:ecostep/presentation/widgets/custom_navigation_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
        child: Listener(
          onPointerUp: (_) =>
              ref.read(audioPlayerServiceProvider).playClickSound(),
          child: !isMobile
              ? webWidget()
              : Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Image.asset(
                        'assets/images/mountains.png',
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width * 4,
                      ),
                    ),
                    PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        HomePage(),
                        LeaderBoardPage(),
                        MarketplaceScreen(),
                        ProfilePage(),
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
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              HomePage(),
              LeaderBoardPage(),
              MarketplaceScreen(),
              ProfilePage(),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: CustomNavigationRail(_pageController),
          ),
        ],
      );
}
