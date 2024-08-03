import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/domain/user.dart';
import 'package:ecostep/domain/marketplace_item.dart';
import 'package:ecostep/domain/purchase_request.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class BuyerPurchaseRequestWidget extends ConsumerStatefulWidget {
  const BuyerPurchaseRequestWidget({
    required this.request,
    required this.requestReference,
    super.key,
  });
  final PurchaseRequest request;
  final DocumentReference requestReference;

  @override
  _BuyerPurchaseRequestWidgetState createState() =>
      _BuyerPurchaseRequestWidgetState();
}

class _BuyerPurchaseRequestWidgetState
    extends ConsumerState<BuyerPurchaseRequestWidget> {
  late Future<Map<String, dynamic>> _additionalData;

  @override
  void initState() {
    super.initState();
    _additionalData =
        _fetchAdditionalData(widget.request.buyerId, widget.request.item);
  }

  Future<Map<String, dynamic>> _fetchAdditionalData(
    DocumentReference buyerId,
    DocumentReference itemRef,
  ) async {
    final buyerSnapshot = await buyerId.get();
    final itemSnapshot = await itemRef.get();

    if (!buyerSnapshot.exists || !itemSnapshot.exists) {
      throw Exception('Document does not exist');
    }

    final buyerData =
        User.fromJson(buyerSnapshot.data()! as Map<String, dynamic>);
    final itemData =
        MarketplaceItem.fromJson(itemSnapshot.data()! as Map<String, dynamic>);

    return {
      'buyer': buyerData,
      'item': itemData,
    };
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    return dateFormat.format(dateTime);
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

        final buyer = snapshot.data!['buyer'] as User;
        final item = snapshot.data!['item'] as MarketplaceItem;

        return SizedBox(
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Purchase Request',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              icon: Icons.person,
                              title: 'Buyer Name:',
                              value: buyer.name ?? 'N/A',
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item.imageUrl,
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
            maxLines: 2,
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
        onPressed: null,
        icon: const Icon(Icons.pending, color: Colors.white),
        label: const Text(
          'Waiting for buyer confirmation',
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
    } else {
      return ElevatedButton.icon(
        onPressed: () async {
          await widget.requestReference.update({
            'sellerConfirm': true,
          });

          showToast(
            ref,
            'Purchase confirmed by seller',
            type: ToastificationType.success,
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Purchase confirmed by seller'),
          //   ),
          // );
          setState(() {});
        },
        icon: const Icon(
          Icons.contact_page,
          color: Colors.white,
        ),
        label: const Text(
          'Confirm Request',
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
    }
  }
}
