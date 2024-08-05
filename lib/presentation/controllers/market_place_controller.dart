import 'package:ecostep/data/market_place_repository.dart';
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'market_place_controller.g.dart';

@riverpod
class MarketplaceController extends _$MarketplaceController {
  @override
  Stream<List<MarketplaceItem>> build() {
    return fetchMarketplaceItems();
  }

  Stream<List<MarketplaceItem>> fetchMarketplaceItems() {
    try {
      final itemsStream =
          // ignore: avoid_manual_providers_as_generated_provider_dependency
          ref.watch(marketplaceRepositoryProvider).fetchMarketplaceItems()
      ..listen((items) {
        state = AsyncData(items);
      });
      return itemsStream;
    } catch (e) {
      debugPrint('Error fetching marketplace items: $e');
      return Stream.error(e);
    }
  }
}
