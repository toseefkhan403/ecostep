import 'dart:io';

import 'package:ecostep/data/gemini_repository.dart';
import 'package:ecostep/domain/verify_image_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyImageController extends StateNotifier<VerifyImageState> {
  VerifyImageController(this.geminiService) : super(const VerifyImageState());

  final GeminiRepository geminiService;

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      final imageBytes = kIsWeb
          ? result.files.single.bytes
          : File(result.files.single.path!).readAsBytesSync();
      state = state.copyWith(
        isloadingImage: true,
        imagebytes: imageBytes,
      );
      await verifyImage(imageBytes!);
    } else {
      state = state.copyWith(isloadingImage: false);
    }
  }

  Future<void> verifyImage(Uint8List imageBytes) async {
    final score = await geminiService.verifyImage(imageBytes);
    state = state.copyWith(verifiedscore: score, isloadingImage: false);
  }
}

final verifyImageControllerProvider =
    StateNotifierProvider<VerifyImageController, VerifyImageState>((ref) {
  final geminiService = ref.read(geminiServiceProvider);
  return VerifyImageController(geminiService);
});
