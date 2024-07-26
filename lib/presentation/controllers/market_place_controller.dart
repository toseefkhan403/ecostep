import 'package:ecostep/application/firestore_service.dart';
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketplaceController extends StateNotifier<List<MarketplaceItem>> {
  MarketplaceController(this.firestoreService) : super([]);

  final FirestoreService firestoreService;

  Future<void> fetchMarketplaceItems() async {
    try {
      final items = await firestoreService.fetchMarketplaceItems();
      state = items;
    } catch (e) {
      debugPrint('Error fetching marketplace items: $e');
    }
  }
}

final marketplaceControllerProvider =
    StateNotifierProvider<MarketplaceController, List<MarketplaceItem>>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return MarketplaceController(firestoreService);
});
