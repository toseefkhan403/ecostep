// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/application/audio_player_service.dart';
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:ecostep/domain/purchase_request.dart';
import 'package:ecostep/domain/user.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:ecostep/presentation/widgets/purchase_completed_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class SellerPurchaseRequestWidget extends ConsumerStatefulWidget {
  const SellerPurchaseRequestWidget({
    required this.request,
    required this.requestRefernce,
    super.key,
  });
  final PurchaseRequest request;
  final DocumentReference requestRefernce;

  @override
  ConsumerState createState() => _SellerPurchaseRequestWidgetState();
}

class _SellerPurchaseRequestWidgetState
    extends ConsumerState<SellerPurchaseRequestWidget> {
  late Future<Map<String, dynamic>> _additionalData;

  @override
  void initState() {
    super.initState();
    _additionalData =
        _fetchAdditionalData(widget.request.sellerId, widget.request.item);
  }

  Future<Map<String, dynamic>> _fetchAdditionalData(
    DocumentReference sellerId,
    DocumentReference itemRef,
  ) async {
    final sellerSnapshot = await sellerId.get();
    final itemSnapshot = await itemRef.get();

    if (!sellerSnapshot.exists || !itemSnapshot.exists) {
      throw Exception('Document does not exist');
    }

    final sellerData =
        User.fromJson(sellerSnapshot.data()! as Map<String, dynamic>);
    final itemData =
        MarketplaceItem.fromJson(itemSnapshot.data()! as Map<String, dynamic>);

    return {
      'seller': sellerData,
      'item': itemData,
    };
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    return dateFormat.format(dateTime);
  }

  Future<bool> _confirmPurchase() async {
    try {
      final buyerDoc = await widget.request.buyerId.get();

      final buyerBalance = buyerDoc['ecoBucksBalance'] as int;
      final price = int.parse(widget.request.buyerPrice);

      if (buyerBalance < price) {
        showToast(
          ref,
          "You don't have sufficient balance.",
          type: ToastificationType.error,
        );

        return false;
      }
      await widget.requestRefernce.update({'buyerConfirm': true});
      await widget.request.item.update({'hasSold': true});

      await widget.request.buyerId.update({
        'ecoBucksBalance': FieldValue.increment(-price),
      });

      await widget.request.sellerId.update({
        'ecoBucksBalance': FieldValue.increment(price),
      });

      showToast(
        ref,
        'Funds transferred',
        type: ToastificationType.success,
      );

      return true;
    } catch (e) {
      debugPrint(e.toString());
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _additionalData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error fetching additional data: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No additional data found'));
        }

        final seller = snapshot.data!['seller'] as User;
        final item = snapshot.data!['item'] as MarketplaceItem;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            return SizedBox(
              child: Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Purchase Request',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (isSmallScreen)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: 250,
                            ),
                          ),
                        ),
                      if (isSmallScreen) const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isSmallScreen) const SizedBox(height: 10),
                                _buildDetailRow(
                                  icon: Icons.person,
                                  title: 'Seller Name:',
                                  value: seller.name ?? 'N/A',
                                ),
                                const SizedBox(height: 10),
                                _buildDetailRow(
                                  icon: Icons.money,
                                  title: 'Buyer Price:',
                                  value: widget.request.buyerPrice,
                                ),
                                const SizedBox(height: 10),
                                _buildDetailRow(
                                  icon: Icons.store,
                                  title: 'Item Name:',
                                  value: item.name,
                                ),
                                const SizedBox(height: 10),
                                _buildDetailRow(
                                  icon: Icons.description,
                                  title: 'Item Description:',
                                  value: item.description,
                                ),
                                const SizedBox(height: 10),
                                _buildDetailRow(
                                  icon: Icons.calendar_today,
                                  title: 'Requested At:',
                                  value: _formatTimestamp(
                                    widget.request.timestamp as Timestamp,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildConfirmButton(),
                              ],
                            ),
                          ),
                          if (!isSmallScreen)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    item.imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    height: 250,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildConfirmButton() {
    if (widget.request.sellerConfirm && widget.request.buyerConfirm) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text(
          'Transaction Confirmed',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      );
    } else if (widget.request.sellerConfirm) {
      return ElevatedButton.icon(
        onPressed: _showConfirmDialog,
        icon: const Icon(Icons.contact_page, color: Colors.white),
        label: const Text(
          'Confirm Purchase',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.pending, color: Colors.white),
        label: const Text(
          'Pending Seller Confirmation',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      );
    }
  }

  Future<void> _showConfirmDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Confirm Purchase',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColors.primaryColor,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LottieIconWidget(
                iconName: 'alert',
                height: 80,
              ),
              Text(
                'Are you sure about the transfer?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '''Please verify the details of your purchase before confirming. Once confirmed, this action cannot be undone.''',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '''Ensure you have reviewed the seller's information and item details.''',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.backgroundColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final sucess = await _confirmPurchase();
                Navigator.of(context).pop();

                await showDialog<void>(
                  context: context,
                  builder: (c) {
                    return PurchaseCompletedDialog(isSuccess: sucess);
                  },
                );

                await ref
                    .read(audioPlayerServiceProvider)
                    .playSound(sucess ? 'success' : 'fail', extension: 'mp3');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.textColor,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          maxLines: 2,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            style: const TextStyle(
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
