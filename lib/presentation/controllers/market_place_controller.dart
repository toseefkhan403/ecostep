import 'package:ecostep/application/firestore_service.dart';
import 'package:ecostep/data/market_place_repository.dart';
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          ref.watch(marketplaceRepositoryProvider).fetchMarketplaceItems();
      itemsStream.listen((items) {
        state = AsyncData(items);
      });
      return itemsStream;
    } catch (e) {
      debugPrint('Error fetching marketplace items: $e');
      return Stream.error(e);
    }
  }
}
