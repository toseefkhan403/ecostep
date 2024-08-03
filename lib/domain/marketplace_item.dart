import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'marketplace_item.freezed.dart';
part 'marketplace_item.g.dart';

@freezed
class MarketplaceItem with _$MarketplaceItem {
  const factory MarketplaceItem({
    required String description,
    required bool hasSold,
    required String imageUrl,
    required String location,
    required String name,
    required String price,
    required dynamic sellingUser,
    required dynamic uploadedAt,
    required int usedForMonths,
    required String docid,
    required String  contactInfo,
  }) = _MarketplaceItem;

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceItemFromJson(json);

  factory MarketplaceItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return MarketplaceItem.fromJson(data);
  }
}
