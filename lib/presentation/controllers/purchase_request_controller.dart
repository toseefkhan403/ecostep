// ignore_for_file: use_build_context_synchronously
import 'package:ecostep/data/market_place_repository.dart';
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseRequestController extends StateNotifier<void> {
  PurchaseRequestController(this.provider) : super(null);

  final MarketPlaceRepository provider;

  Future<bool> sendPurchaseRequest({
    required MarketplaceItem item,
    required BuildContext context,
    required String enteredprice,
  }) async {
    try {
      await provider.sendPurchaseRequest(item: item, buyerprice: enteredprice);

      return true;
    } catch (e) {
      debugPrint('Error sending purchase request: $e');
      return false;
    }
  }
}

final purchaseRequestControllerProvider =
    StateNotifierProvider<PurchaseRequestController, void>((ref) {
  final provider = ref.read(marketplaceRepositoryProvider);
  return PurchaseRequestController(provider);
});
