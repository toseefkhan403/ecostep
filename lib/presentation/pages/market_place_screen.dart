// ignore_for_file: inference_failure_on_function_invocation
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:ecostep/presentation/controllers/market_place_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/async_value_widget.dart';
import 'package:ecostep/presentation/widgets/market_place_card.dart';
import 'package:ecostep/presentation/widgets/post_item_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) {
    //     ref
    //         .read(marketplaceControllerProvider.notifier)
    //         .fetchMarketplaceItems();
    //   },
    // );

    // for (var i = 0; i < 10; i++) {
    //   marketplaceItems.add(marketplaceItems.first);
    // }
  }

  List<MarketplaceItem> getFilteredItems(
    List<MarketplaceItem> items,
    String? currentUserUid,
  ) {
    return items.where((item) {
      final sellingUserId = item.sellingUser.id;
      return sellingUserId == currentUserUid;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final marketplaceItemsvalue = ref.watch(marketplaceControllerProvider);
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return AsyncValueWidget(
      value: marketplaceItemsvalue,
      data: (marketplaceitems) {
        final filteredItems =
            getFilteredItems(marketplaceitems, currentUserUid);
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: CircularElevatedButton(
            color: AppColors.secondaryColor,
            height: 60,
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
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(10),
                                itemCount: marketplaceitems.length,
                                itemBuilder: (context, index) {
                                  final item = marketplaceitems[index];
                                  return SizedBox(
                                    height: 400,
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
                              child: GridView.builder(
                                padding: const EdgeInsets.all(10),
                                gridDelegate:
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
                            return ListView.builder(
                              padding: const EdgeInsets.all(10),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return SizedBox(
                                  height: 400,
                                  child: MarketplaceCard(
                                    item: item,
                                    isShowDetails: false,
                                  ),
                                );
                              },
                            );
                          } else {
                            return GridView.builder(
                              padding: const EdgeInsets.all(10),
                              gridDelegate:
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Items For Recycle',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 30,
            ),
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
