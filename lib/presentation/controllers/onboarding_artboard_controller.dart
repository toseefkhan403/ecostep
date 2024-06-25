import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class OnboardingArtboardController extends StateNotifier<Artboard?> {
  OnboardingArtboardController(this.pageNo) : super(null);

  SMITrigger? next;
  SMITrigger? _showTapText;
  int pageNo;

  Future<void> loadRiveFile({bool isSmallScreen = false}) async {
    debugPrint("loading rive file");
    final file = await RiveFile.asset('assets/rive_assets/greenloop.riv');

    final artboard = file.artboardByName(isSmallScreen
        ? 'Onboarding${pageNo}Small'
        : 'Onboarding${pageNo}Large');
    if (artboard == null) return;

    var controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);
      next = controller.getTriggerInput('continue');
      _showTapText = controller.getTriggerInput('showTapToContinue');
    }
    state = artboard;
    Future.delayed(
        const Duration(seconds: 3), () => _showTapText?.value = true);
  }
}

final onboardingArtboardControllerProvider =
    StateNotifierProvider<OnboardingArtboardController, Artboard?>(
  (ref) => OnboardingArtboardController(1),
);
