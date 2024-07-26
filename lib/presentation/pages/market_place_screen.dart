import 'package:ecostep/presentation/controllers/market_place_controller.dart';
import 'package:ecostep/presentation/widgets/market_place_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final marketplaceItems = ref.watch(marketplaceControllerProvider);
    final isLoading = marketplaceItems.isEmpty;
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
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
          );
  }
}
