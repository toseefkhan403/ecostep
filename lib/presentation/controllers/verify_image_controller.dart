import 'package:ecostep/application/audio_player_service.dart';
import 'package:ecostep/data/gemini_repository.dart';
import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/domain/verify_image_state.dart';
import 'package:ecostep/presentation/controllers/week_state_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verify_image_controller.g.dart';

@riverpod
class VerifyImageController extends _$VerifyImageController {
  @override
  VerifyImageState build() => const VerifyImageState(isLoadingImage: false);

  Future<void> pickImage(String verifiableImage, int reward) async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (result != null) {
      final imageBytes = await result.readAsBytes();
      state = state.copyWith(
        isLoadingImage: true,
        imageBytes: imageBytes,
      );
      await verifyImage(imageBytes, verifiableImage, reward);
    } else {
      state = state.copyWith(isLoadingImage: false);
    }
  }

  Future<void> verifyImage(
    Uint8List imageBytes,
    String verifiableImage,
    int reward,
  ) async {
    try {
      final verification = await ref
          .read(geminiRepositoryProvider)
          .verifyImage(imageBytes, verifiableImage);
      final score = int.parse(verification['verifiedScore'] as String);
      debugPrint('image score: $score');

      state = state.copyWith(
        isLoadingImage: false,
        verificationSuccess: score > 50,
        imageAnalysis: verification['imageAnalysis'] as String,
      );
      if (score > 50) {
        final selectedDate =
            ref.watch(weekStateControllerProvider).selectedDate;
        final userProvider = ref.read(userRepositoryProvider);
        await userProvider.addEcoBucks(reward);
        await userProvider.completeUserAction(selectedDate);
        await userProvider.updateStreak();
        await ref
            .read(audioPlayerServiceProvider)
            .playSound('success', extension: 'mp3');
      } else {
        await ref
            .read(audioPlayerServiceProvider)
            .playSound('fail', extension: 'mp3');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
