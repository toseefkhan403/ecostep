// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/application/audio_player_service.dart';
import 'package:ecostep/domain/purchase_request.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:ecostep/presentation/widgets/purchase_completed_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class ConfirmTransactionDialog extends ConsumerStatefulWidget {
  const ConfirmTransactionDialog(
    this.request,
    this.requestReference, {
    super.key,
  });

  final PurchaseRequest request;
  final DocumentReference requestReference;

  @override
  ConsumerState<ConfirmTransactionDialog> createState() =>
      _ConfirmTransactionDialogState();
}

class _ConfirmTransactionDialogState
    extends ConsumerState<ConfirmTransactionDialog> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return CenterContentPadding(
      child: AlertDialog(
        insetPadding: isMobileScreen(context)
            ? const EdgeInsets.all(10)
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Confirm Purchase',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: AppColors.primaryColor,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LottieIconWidget(
              iconName: 'alert',
              height: 80,
              autoPlay: true,
            ),
            Text(
              'Are you sure about the transfer?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '''Please verify the details of your purchase before confirming. Once confirmed, this action cannot be undone.''',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '''Ensure you have reviewed the seller's information and item details.''',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Semantics(
            label: 'Cancel',
            child: TextButton(
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
          ),
          Semantics(
            label: 'Confirm transaction',
            child: ElevatedButton(
              onPressed: () async {
                if (isProcessing) return;

                setState(() {
                  isProcessing = true;
                });
                final success = await _confirmPurchase();
                await ref.read(audioPlayerServiceProvider).playSound(
                      success ? 'success' : 'fail',
                      extension: 'mp3',
                    );
                await showDialog<void>(
                  context: context,
                  builder: (c) {
                    return PurchaseCompletedDialog(isSuccess: success);
                  },
                );
                setState(() {
                  isProcessing = false;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
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

      await widget.requestReference.update({'buyerConfirm': true});
      await widget.request.item.update({'hasSold': true});

      await widget.request.buyerId.update({
        'ecoBucksBalance': FieldValue.increment(-price),
      });

      await widget.request.sellerId.update({
        'ecoBucksBalance': FieldValue.increment(price),
      });

      return true;
    } catch (e) {
      debugPrint('Failed to transfer funds $e');
    }

    return false;
  }
}
