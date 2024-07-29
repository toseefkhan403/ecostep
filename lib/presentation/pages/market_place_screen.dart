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
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
       
          floatingActionButton: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const PostItemDialog();
                },
              );
            },
            child: const Text('add item'),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: !isMobileScreen(context) ? width * 0.25 : 10,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Row(
                    children: [
                      Text(
                        'Market Place',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 26.sp,
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
                      Container(
                        margin: EdgeInsets.only(top: 20.h),
                        padding: EdgeInsets.all(20.w),
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
                              item: item,
                            );
                          },
                        ),
                      ),
                      GridView.builder(
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
                            item: item,
                          );
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
                    'All Items',
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
                    'Your Items',
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
