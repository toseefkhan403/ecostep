import 'package:ecostep/domain/action.dart';
import 'package:ecostep/presentation/controllers/verify_image_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyImageDialog extends ConsumerWidget {
  const VerifyImageDialog(this.action, {required this.hasVerified, super.key});

  final Action action;
  final bool hasVerified;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verifyImageControllerProvider);
    final controller = ref.read(verifyImageControllerProvider.notifier);
    final reward = coinsFromDifficulty(action.difficulty.toLowerCase());

    final dialogWidth = !isMobileScreen(context)
        ? MediaQuery.of(context).size.width * 0.5
        : 300.0;

    return CenterContentPadding(
      child: AlertDialog(
        title: const Text(
          'Image Verification',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: hasVerified
              ? _verifiedAlready()
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: (state.isLoadingImage)
                      ? _analyzingImage(
                          key: const ValueKey('verifyImageDialog.1'),
                        )
                      : (state.verificationSuccess != null)
                          ? _verificationStatus(
                              key: const ValueKey('verifyImageDialog.2'),
                              verificationSuccess: state.verificationSuccess!,
                              imageAnalysis: state.imageAnalysis,
                              reward: reward,
                            )
                          : Column(
                              key: const ValueKey('verifyImageDialog.3'),
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '''Verify your action image with Gemini AI ✨''',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: _imageDescription(
                                    action.difficulty,
                                    reward,
                                  ),
                                ),
                              ],
                            ),
                ),
        ),
        actions: [
          if (state.verificationSuccess == null &&
              !state.isLoadingImage &&
              !hasVerified)
            FilledButton(
              onPressed: () => controller.pickImage(
                action.verifiableImage,
                reward,
              ),
              child: const Text('Camera'),
            ),
          if (state.verificationSuccess == null &&
              !state.isLoadingImage &&
              !hasVerified)
            FilledButton(
              onPressed: () => controller.pickImage(
                action.verifiableImage,
                reward,
                isCamera: false,
              ),
              child: const Text('Gallery'),
            ),
          if (!state.isLoadingImage)
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(state.verificationSuccess),
              child: const Text('Exit'),
            ),
        ],
      ),
    );
  }

  Widget _imageDescription(String difficulty, int reward) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              children: <TextSpan>[
                const TextSpan(
                  text:
                      '''You must verify your action with an image. Please upload an image with the following content: \n\n''',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: action.verifiableImage,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Text(
                "EcoBucks you'll get after verification: ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const LottieIconWidget(iconName: 'coin'),
              Text(
                '$reward',
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Text(
            '''[Note] Gallery option is available for testing purposes only. Image verification should be done via Camera for better accountability.''',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textColor,
            ),
          ),
        ],
      );

  Widget _analyzingImage({required ValueKey<String> key}) => Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: const [
          LottieIconWidget(
            iconName: 'search-file',
            height: 150,
            repeat: true,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Analyzing Image...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );

  Widget _verificationStatus({
    required ValueKey<String> key,
    required bool verificationSuccess,
    required String? imageAnalysis,
    required int reward,
  }) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LottieIconWidget(
            iconName: verificationSuccess ? 'right-decision' : 'wrong-decision',
            height: 150,
            repeat: true,
          ),
          Text(
            '''Verification ${verificationSuccess ? 'successful' : 'failed'}!''',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            verificationSuccess
                ? '''Action has been verified successfully. $reward EcoBucks has been successfully added to your account.'''
                : """Image verification failed! Here's the analysis: $imageAnalysis""",
            style: const TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );

  Widget _verifiedAlready() => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LottieIconWidget(
            iconName: 'right-decision',
            height: 150,
            repeat: true,
          ),
          Text(
            'Action has been completed and verified already!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
}
