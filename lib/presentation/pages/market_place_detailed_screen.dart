import 'package:ecostep/domain/marketplace_item.dart';
import 'package:ecostep/presentation/controllers/purchase_request_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketplaceDetailScreen extends ConsumerWidget {
  const MarketplaceDetailScreen({required this.item, super.key});
  final MarketplaceItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseRequestController =
        ref.read(purchaseRequestControllerProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.imageUrl,
                  height: 400,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 24,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.location,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Price: ${item.price}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Used for: ${item.usedForMonths} months',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await purchaseRequestController.sendPurchaseRequest(
                      item,
                      context,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: const Text(
                    'Request to buy',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
