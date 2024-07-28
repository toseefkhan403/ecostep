import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_image_state.freezed.dart';

@freezed
class VerifyImageState with _$VerifyImageState {
  const factory VerifyImageState({
    required bool isLoadingImage,
    Uint8List? imageBytes,
    bool? verificationSuccess,
    String? imageAnalysis,
  }) = _VerifyImageState;
}
