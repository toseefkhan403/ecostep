import 'package:ecostep/domain/marketplace_item.dart';
import 'package:ecostep/presentation/controllers/purchase_request_controller.dart';
import 'package:ecostep/presentation/pages/market_place_detailed_screen.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/expired_overlay.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class MarketplaceCard extends StatefulWidget {
  const MarketplaceCard({
    required this.item,
    required this.isShowDetails,
    super.key,
  });
  final bool isShowDetails;
  final MarketplaceItem item;

  @override
  State<MarketplaceCard> createState() => _MarketplaceCardState();
}

class _MarketplaceCardState extends State<MarketplaceCard> {
  void showDetailDialog(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var isRequestButtonEnabled = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                        child: Form(
                          key: formKey,
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
                              Row(
                                children: [
                                  Text(
                                    'Price: ${widget.item.price}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  const LottieIconWidget(
                                    iconName: 'coin',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Used for: ${widget.item.usedForMonths} months',
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Contact Information: ${widget.item.contactInfo}',
                                style: const TextStyle(
                                  fontSize: 18,
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
                              if (widget.isShowDetails)
                                Column(
                                  children: [
                                    TextFormField(
                                      controller: priceController,
                                      decoration: const InputDecoration(
                                        labelText: 'Enter your price',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelStyle:
                                            TextStyle(color: Colors.blueGrey),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter the price';
                                        }
                                        final enteredPrice =
                                            int.tryParse(value);
                                        if (enteredPrice == null) {
                                          return 'Please enter a valid number';
                                        }

                                        final itemPrice = widget.item.price;
                                        if (itemPrice.contains('-')) {
                                          final parts = itemPrice.split('-');
                                          final minPrice =
                                              int.tryParse(parts[0]);
                                          final maxPrice =
                                              int.tryParse(parts[1]);
                                          if (minPrice == null ||
                                              maxPrice == null) {
                                            return 'Invalid price range';
                                          }
                                          if (enteredPrice < minPrice ||
                                              enteredPrice > maxPrice) {
                                            return 'Price must be within the range $itemPrice';
                                          }
                                        } else {
                                          final fixedPrice =
                                              int.tryParse(itemPrice);
                                          if (fixedPrice == null) {
                                            return 'Invalid price';
                                          }
                                          if (enteredPrice != fixedPrice) {
                                            return 'Price must be $fixedPrice';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: isRequestButtonEnabled
                                            ? () async {
                                                if (formKey.currentState
                                                        ?.validate() ??
                                                    false) {
                                                  setState(() {
                                                    isRequestButtonEnabled =
                                                        false;
                                                  });
                                                  await purchaseRequestController
                                                      .sendPurchaseRequest(
                                                    item: widget.item,
                                                    context: context,
                                                    enteredprice:
                                                        priceController.text,
                                                  );
                                                } else {
                                                  showToast(
                                                    ref,
                                                    'Please enter a valid price',
                                                    type: ToastificationType
                                                        .error,
                                                  );
                                                  // ScaffoldMessenger.of(context)
                                                  //     .showSnackBar(
                                                  //   const SnackBar(
                                                  //     content: Text(
                                                  //       'Please enter a valid price',
                                                  //     ),
                                                  //   ),
                                                  // );
                                                }
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          backgroundColor:
                                              isRequestButtonEnabled
                                                  ? AppColors.primaryColor
                                                  : Colors.grey,
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
                                )
                              else
                                const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.item.imageUrl);

    return GestureDetector(
      onTap: widget.item.hasSold
          ? null
          : () {
              showDetailDialog(context);
            },
      child: SizedBox(
        child: Card(
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ExpiredOverlay(
              expiredMessage: 'SOLD OUT',
              messageColor: Colors.red.withOpacity(0.7),
              isExpired: widget.item.hasSold,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Flexible(
                        child: SingleChildScrollView(
                          child: Padding(
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
                                        color: AppColors.primaryColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 4),
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
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Contact Information: ${widget.item.contactInfo}',
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
        ),
      ),
    );
  }
}
