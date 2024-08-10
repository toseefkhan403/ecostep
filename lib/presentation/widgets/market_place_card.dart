// ignore_for_file: avoid_dynamic_calls, use_build_context_synchronously, lines_longer_than_80_chars
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/application/audio_player_service.dart';
import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:ecostep/presentation/controllers/purchase_request_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/async_value_widget.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/expired_overlay.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:ecostep/presentation/widgets/request_confirm_dialog.dart';
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
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var isRequestButtonEnabled = true;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CenterContentPadding(
              child: Dialog(
                insetPadding: isMobileScreen(context)
                    ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                    : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final purchaseRequestController =
                        ref.read(purchaseRequestControllerProvider.notifier);
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  widget.item.imageUrl,
                                  height: isMobileScreen(context) ? 250 : 350,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const LottieIconWidget(
                                    iconName: 'pin',
                                    height: 40,
                                  ),
                                  Text(
                                    widget.item.location,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.item.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Price: ${widget.item.price}',
                                    style: const TextStyle(
                                      fontSize: 18,
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
                                '''Used for: ${formatMonths(widget.item.usedForMonths)}''',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '''Contact Information: ${widget.item.contactInfo}''',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.item.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 20),
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
                                            return '''Price must be within the range $itemPrice''';
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
                                      child: Consumer(
                                        builder: (context, ref, child) {
                                          final uservalue =
                                              ref.watch(firestoreUserProvider);

                                          return AsyncValueWidget(
                                            value: uservalue,
                                            loading: () => const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            data: (user) =>
                                                CircularElevatedButton(
                                              color: AppColors.primaryColor,
                                              width: 200,
                                              onPressed: () async {
                                                if (!isRequestButtonEnabled) {
                                                  return;
                                                }

                                                if (formKey.currentState
                                                        ?.validate() ??
                                                    false) {
                                                  final userSnapshot =
                                                      await widget
                                                              .item.sellingUser
                                                              .get()
                                                          as DocumentSnapshot;

                                                  final itemUserId =
                                                      userSnapshot.get('id');

                                                  if (itemUserId == user.id) {
                                                    showToast(
                                                      ref,
                                                      '''You can't buy your own item''',
                                                      type: ToastificationType
                                                          .error,
                                                    );

                                                    return;
                                                  }
                                                  final itemPrice = int.parse(
                                                    widget.item.price,
                                                  );

                                                  if (user.ecoBucksBalance <
                                                      itemPrice) {
                                                    showToast(
                                                      ref,
                                                      '''Insufficient balance''',
                                                      type: ToastificationType
                                                          .error,
                                                    );

                                                    return;
                                                  }
                                                  setState(() {
                                                    isRequestButtonEnabled =
                                                        false;
                                                  });

                                                  final isSucess =
                                                      await purchaseRequestController
                                                          .sendPurchaseRequest(
                                                    item: widget.item,
                                                    context: context,
                                                    enteredprice:
                                                        priceController.text,
                                                  );

                                                  await ref
                                                      .read(
                                                        audioPlayerServiceProvider,
                                                      )
                                                      .playSound(
                                                        'success',
                                                        extension: 'mp3',
                                                      );
                                                  await showDialog<void>(
                                                    context: context,
                                                    builder: (c) {
                                                      return RequestConfirmPurchase(
                                                        isSuccess: isSucess,
                                                      );
                                                    },
                                                  );
                                                  Navigator.pop(context);
                                                } else {
                                                  showToast(
                                                    ref,
                                                    '''Please enter a valid price''',
                                                    type: ToastificationType
                                                        .error,
                                                  );
                                                }
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 7,
                                                ),
                                                child: Text(
                                                  'Request to buy',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
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
    return GestureDetector(
      onTap: widget.item.hasSold
          ? null
          : () {
              showDetailDialog(context);
            },
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
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image.network(
                          widget.item.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const LottieIconWidget(
                                  iconName: 'pin',
                                  height: 40,
                                ),
                                Text(
                                  widget.item.location,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                                const SizedBox(width: 2),
                                const LottieIconWidget(
                                  iconName: 'coin',
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      '''Used for: ${formatMonths(widget.item.usedForMonths)}''',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    child: AutoSizeText(
                                      widget.item.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }
}
