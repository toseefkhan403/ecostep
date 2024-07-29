import 'package:ecostep/domain/marketplace_item.dart';
import 'package:ecostep/presentation/controllers/purchase_request_controller.dart';
import 'package:ecostep/presentation/pages/market_place_detailed_screen.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketplaceCard extends StatefulWidget {
  const MarketplaceCard({
    required this.item,
    super.key,
  });
  final MarketplaceItem item;

  @override
  State<MarketplaceCard> createState() => _MarketplaceCardState();
}

class _MarketplaceCardState extends State<MarketplaceCard> {
  void showDetailDialog(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: !isMobileScreen(context) ? width * 0.25 : 10,
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Consumer(
              builder: (context, ref, child) {
                final purchaseRequestController =
                    ref.read(purchaseRequestControllerProvider.notifier);
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.item.imageUrl,
                            height: 350,
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
                              widget.item.location,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.item.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Price: ${widget.item.price}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Used for: ${widget.item.usedForMonths} months',
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.item.description,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              await purchaseRequestController
                                  .sendPurchaseRequest(
                                widget.item,
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
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
  print(widget.item.imageUrl);

  return GestureDetector(
    onTap: () {
      showDetailDialog(context);
    },
    child: SizedBox(
      child: Card(
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: Image.network(
                        widget.item.imageUrl,
                        width: double.infinity,
                        height: constraints.maxWidth * 0.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.item.location,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.item.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                'Price: ${widget.item.price}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.attach_money,
                                size: 16,
                                color: Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Used for: ${widget.item.usedForMonths} months',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.item.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

}
