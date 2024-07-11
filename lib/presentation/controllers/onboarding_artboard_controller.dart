import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class OnboardingArtboardController extends StateNotifier<Artboard?> {
  OnboardingArtboardController(this.pageNo) : super(null);

  SMITrigger? next;
  SMITrigger? end;
  SMITrigger? _showTapText;
  int pageNo;

  Future<void> loadRiveFile({bool isSmallScreen = false}) async {
    debugPrint('loading rive file');
    final file = await RiveFile.asset('assets/rive_assets/greenloop.riv');

    final artboard = file.artboardByName(
      isSmallScreen ? 'Onboarding${pageNo}Small' : 'Onboarding${pageNo}Large',
    );
    if (artboard == null) return;

    final controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);
      next = controller.getTriggerInput('continue');
      end = controller.getTriggerInput('end');
      _showTapText = controller.getTriggerInput('showTapToContinue');
    }
    state = artboard;
    Future.delayed(
      const Duration(seconds: 3),
      () => _showTapText?.value = true,
    );
  }

  Future<void> animateToNextPage({bool isSmallScreen = false}) {
    pageNo++;
    next?.value = true;
    return Future.delayed(const Duration(milliseconds: 800), () {
      loadRiveFile(
        isSmallScreen: isSmallScreen,
      );
    });
  }

  void getStarted() {
    end?.value = true;
  }
}

final onboardingArtboardControllerProvider =
    StateNotifierProvider.autoDispose<OnboardingArtboardController, Artboard?>(
  (ref) => OnboardingArtboardController(1),
);
