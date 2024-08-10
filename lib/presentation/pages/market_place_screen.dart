// ignore_for_file: inference_failure_on_function_invocation
import 'package:ecostep/presentation/controllers/market_place_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/async_value_widget.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:ecostep/presentation/widgets/market_place_card.dart';
import 'package:ecostep/presentation/widgets/post_item_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final marketplaceItemsvalue = ref.watch(marketplaceControllerProvider);
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: isMobileScreen(context) ? 55.0 : 0),
        child: CircularElevatedButton(
          color: AppColors.secondaryColor,
          height: isMobileScreen(context) ? 45 : 60,
          width: isMobileScreen(context) ? 130 : 150,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const PostItemDialog();
              },
            );
          },
          child: const Text(
            'Post Item',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: !isMobileScreen(context) ? width * 0.25 : 10,
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Marketplace',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 26,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            _buttonRow(),
            Expanded(
              child: AsyncValueWidget(
                value: marketplaceItemsvalue,
                data: (marketplaceitems) {
                  final filteredItems =
                      getUserSellerItems(marketplaceitems, currentUserUid);
                  return PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              child: marketplaceitems.isEmpty
                                  ? const Center(
                                      child: LottieIconWidget(
                                        autoPlay: true,
                                        iconName: 'not-found',
                                        height: 120,
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(10),
                                      itemCount: marketplaceitems.length,
                                      itemBuilder: (context, index) {
                                        final item = marketplaceitems[index];

                                        return SizedBox(
                                          height: 500,
                                          child: MarketplaceCard(
                                            isShowDetails: true,
                                            item: item,
                                          ),
                                        );
                                      },
                                    ),
                            );
                          } else {
                            return Container(
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(20),
                              child: marketplaceitems.isEmpty
                                  ? const Center(
                                      child: LottieIconWidget(
                                        autoPlay: true,
                                        iconName: 'not-found',
                                        height: 120,
                                      ),
                                    )
                                  : GridView.builder(
                                      padding: const EdgeInsets.all(10),
                                      gridDelegate:
                                          // ignore: lines_longer_than_80_chars
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.8,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: marketplaceitems.length,
                                      itemBuilder: (context, index) {
                                        final item = marketplaceitems[index];
                                        return MarketplaceCard(
                                          isShowDetails: true,
                                          item: item,
                                        );
                                      },
                                    ),
                            );
                          }
                        },
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            return filteredItems.isEmpty
                                ? const Center(
                                    child: LottieIconWidget(
                                      autoPlay: true,
                                      iconName: 'not-found',
                                      height: 120,
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(10),
                                    itemCount: filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = filteredItems[index];
                                      return SizedBox(
                                        height: 500,
                                        child: MarketplaceCard(
                                          item: item,
                                          isShowDetails: false,
                                        ),
                                      );
                                    },
                                  );
                          } else {
                            return filteredItems.isEmpty
                                ? const Center(
                                    child: LottieIconWidget(
                                      autoPlay: true,
                                      iconName: 'not-found',
                                      height: 120,
                                    ),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.all(10),
                                    gridDelegate:
                                        // ignore: lines_longer_than_80_chars
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.8,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount: filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = filteredItems[index];
                                      return MarketplaceCard(
                                        isShowDetails: false,
                                        item: item,
                                      );
                                    },
                                  );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            if (isMobileScreen(context)) const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buttonRow() => Padding(
        padding: const EdgeInsets.all(8),
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
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    isMobileScreen(context)
                        ? 'For Recycle'
                        : 'Items For Recycle',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: CircularElevatedButton(
                color: _selectedIndex == 1
                    ? AppColors.secondaryColor
                    : AppColors.backgroundColor,
                onPressed: () => _onItemTapped(1),
                blurRadius: _selectedIndex == 1 ? 1 : 5,
                darkShadow: _selectedIndex == 1,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Your Recycles',
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
}
