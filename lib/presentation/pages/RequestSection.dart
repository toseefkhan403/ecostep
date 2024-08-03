import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/domain/user.dart';
import 'package:ecostep/domain/purchase_request.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/widgets/buyer_purchase_widget.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/seller_purchase_request_widget1.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

class RequestSection extends ConsumerStatefulWidget {
  const RequestSection({
    required this.user,
    required this.profilePageController,
    super.key,
  });
  final User user;
  final PageController profilePageController;

  @override
  ConsumerState<RequestSection> createState() => _RequestSectionState();
}

class _RequestSectionState extends ConsumerState<RequestSection> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  Stream<List<PurchaseRequest>> _purchaseRequestsStream(
    List<DocumentReference> references,
  ) {
    final streams = references.map((ref) {
      return ref.snapshots().map((docSnapshot) {
        if (docSnapshot.exists) {
          return PurchaseRequest.fromJson(
            docSnapshot.data()! as Map<String, dynamic>,
          );
        } else {
          print('Document does not exist: ${ref.path}');
          return null;
        }
      });
    }).toList();

    return Rx.combineLatest<PurchaseRequest?, List<PurchaseRequest>>(
      streams,
      (List<PurchaseRequest?> results) {
        return results.whereType<PurchaseRequest>().toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.user.buyerRequests);
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    widget.profilePageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(CupertinoIcons.back),
                ),
                const Expanded(
                  child: Text(
                    'Pending Requests',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 26,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buttonRow(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildRequestsList(widget.user.buyerRequests ?? [], true),
                _buildRequestsList(widget.user.sellerRequests ?? [], false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(List<DocumentReference> requests, bool isBuyer) {
    return StreamBuilder<List<PurchaseRequest>>(
      stream: _purchaseRequestsStream(requests),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error fetching requests: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No requests found'));
        }
        final requestsList = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: requestsList.length,
          itemBuilder: (context, index) {
            final request = requestsList[index];
            return isBuyer
                ? BuyerPurchaseRequestWidget(
                    requestReference: requests[index],
                    request: request,
                  )
                : SellerPurchaseRequestWidget(
                    request: request,
                    requestRefernce: requests[index],
                  );
          },
        );
      },
    );
  }

  Widget _buttonRow() => Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: CircularElevatedButton(
                color: _selectedIndex == 0
                    ? AppColors.secondaryColor
                    : AppColors.backgroundColor,
                blurRadius: _selectedIndex == 0 ? 1 : 5,
                darkShadow: _selectedIndex == 0,
                onPressed: () => _onItemTapped(0),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Incoming Requests',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 30,
            ),
            Expanded(
              child: CircularElevatedButton(
                color: _selectedIndex == 1
                    ? AppColors.secondaryColor
                    : AppColors.backgroundColor,
                onPressed: () => _onItemTapped(1),
                blurRadius: _selectedIndex == 1 ? 1 : 5,
                darkShadow: _selectedIndex == 1,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'My Requests',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
