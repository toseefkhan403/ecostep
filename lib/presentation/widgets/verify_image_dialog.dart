import 'package:ecostep/presentation/controllers/verify_image_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class VerifyImageDialog extends ConsumerWidget {
  const VerifyImageDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verifyImageControllerProvider);
    final controller = ref.read(verifyImageControllerProvider.notifier);
    final isLoading = state.isloadingImage ?? false;

    return Dialog(
      child: Container(
        width: 540,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow()],
        ),
        child: isLoading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Loading...'),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Image Verification',
                    style: TextStyle(
                      color:  Color.fromRGBO(113, 55, 73, 1),
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(
                    width: 352,
                    child: Text(
                      '''Verify your action image with AI ✨ to receive your reward''',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:  Color.fromRGBO(113, 55, 73, 1),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 19,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: state.verifiedscore != null
                        ? Column(
                            children: [
                              Text(
                                '''Verified successfully! Score: ${state.verifiedscore}''',
                                style: const TextStyle(
                                  color:  Color.fromRGBO(113, 55, 73, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const Text(
                                'Reward added to your account :)',
                                style: TextStyle(
                                  color:  Color.fromRGBO(113, 55, 73, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          )
                        : RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Image description: ',
                                  style: TextStyle(
                                    color: Color.fromRGBO(113, 55, 73, 1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '''Image showing the user participating in a volunteer activity for an environmental organization (planting trees, cleaning a beach, etc.).''',
                                  style: TextStyle(
                                    color: Color.fromRGBO(113, 55, 73, 1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  if (state.verifiedscore != null)
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Exit'),
                    )
                  else
                    ElevatedButton(
                      onPressed: controller.pickImage,
                      child: const Text('Select Image'),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
