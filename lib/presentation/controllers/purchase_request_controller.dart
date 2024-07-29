// ignore_for_file: use_build_context_synchronously
import 'package:ecostep/application/firestore_service.dart';
import 'package:ecostep/data/market_place_repository.dart';
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:ecostep/presentation/utils/show_dalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseRequestController extends StateNotifier<void> {
  PurchaseRequestController(this.provider) : super(null);

  final MarketPlaceRepository provider;

  Future<void> sendPurchaseRequest(
    MarketplaceItem item,
    BuildContext context,
  ) async {
    try {
      await provider.sendPurchaseRequest(item);

      showAlertDialog(
        context,
        content: 'Request sent successfully',
        title: 'Success',
      );
    } catch (e) {
      debugPrint('Error sending purchase request: $e');

      showAlertDialog(
        context,
        content: 'Failed to send request',
        title: 'Error',
      );
    }
  }
}

final purchaseRequestControllerProvider =
    StateNotifierProvider<PurchaseRequestController, void>((ref) {
  final provider = ref.read(marketplaceRepositoryProvider);
  return PurchaseRequestController(provider);
});
