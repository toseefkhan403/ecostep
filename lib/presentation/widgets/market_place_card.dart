import 'package:ecostep/domain/marketplace_item.dart';
import 'package:ecostep/presentation/pages/market_place_detailed_screen.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          // ignore: inference_failure_on_instance_creation
          MaterialPageRoute(
            builder: (context) => MarketplaceDetailScreen(item: widget.item),
          ),
        );
      },
      child: SizedBox(
        child: Card(
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            child: Column(
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
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Positioned(
                    //   top: 10,
                    //   right: 10,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 6,
                    //       vertical: 2,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: Colors.black54,
                    //       borderRadius: BorderRadius.circular(15),
                    //     ),
                    //     child: const Row(
                    //       children: [
                    //         LottieIconWidget(
                    //           iconName: 'coin',
                    //         ),
                    //         SizedBox(width: 4),
                    //         Text(
                    //           '5',
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 14,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
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
                          Text(
                            widget.item.location,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                          ),
                          const LottieIconWidget(
                            iconName: 'coin',
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Used for: ${widget.item.usedForMonths} months',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.item.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
