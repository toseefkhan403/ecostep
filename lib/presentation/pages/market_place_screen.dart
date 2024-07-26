import 'package:ecostep/presentation/controllers/market_place_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/market_place_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref
            .read(marketplaceControllerProvider.notifier)
            .fetchMarketplaceItems();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final marketplaceItems = ref.watch(marketplaceControllerProvider);
    final isLoading = marketplaceItems.isEmpty;

    for (var i = 0; i < 10; i++) {
      marketplaceItems.add(marketplaceItems.first);
    }
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsets.symmetric(
              horizontal: !isMobileScreen(context) ? width * 0.25 : 10,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text(
                    'Market Place',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 26.sp,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: marketplaceItems.length,
                    itemBuilder: (context, index) {
                      final item = marketplaceItems[index];
                      return MarketplaceCard(
                        item: item,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
