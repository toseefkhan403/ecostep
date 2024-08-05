import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/data/document_refernce_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_request.freezed.dart';
part 'purchase_request.g.dart';

@freezed
class PurchaseRequest with _$PurchaseRequest {
  const factory PurchaseRequest({
    @DocumentReferenceConverter() required DocumentReference buyerId,
    required String buyerPrice,
    required bool buyerConfirm,
    @DocumentReferenceConverter() required DocumentReference item,
    @DocumentReferenceConverter() required DocumentReference sellerId,
    required bool sellerConfirm,
    required dynamic timestamp,
  }) = _PurchaseRequest;

  factory PurchaseRequest.fromJson(Map<String, Object?> json) =>
      _$PurchaseRequestFromJson(json);
}
