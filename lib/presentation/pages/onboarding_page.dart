import 'package:ecostep/presentation/controllers/onboarding_artboard_controller.dart';
import 'package:ecostep/presentation/utils/adaptive_policy.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  // spam click protection
  bool inTransition = false;

  @override
  void initState() {
    super.initState();
    ref
        .read(onboardingArtboardControllerProvider.notifier)
        .loadRiveFile(isSmallScreen: AdaptivePolicy.isMobile());
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(onboardingArtboardControllerProvider.notifier);
    final artboard = ref.watch(onboardingArtboardControllerProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: artboard == null
          ? const SizedBox()
          : LayoutBuilder(builder: (context, constraints) {
              if (isMobileScreen(context) && artboard.name.contains("Large")) {
                controller.loadRiveFile(isSmallScreen: true);
              } else if (!isMobileScreen(context) &&
                  artboard.name.contains("Small")) {
                controller.loadRiveFile(isSmallScreen: false);
              }
              return GestureDetector(
                onTap: () {
                  if (!inTransition) {
                    inTransition = true;
                    controller.pageNo++;
                    controller.next?.value = true;
                    Future.delayed(const Duration(milliseconds: 1200), () {
                      controller.loadRiveFile(
                        isSmallScreen: constraints.maxWidth < 420,
                      );
                    }).then((_) {
                      Future.delayed(const Duration(seconds: 3), () {
                        inTransition = false;
                      });
                    });
                  }
                },
                child: Rive(
                  artboard: artboard,
                  fit: artboard.name.contains("Small")
                      ? BoxFit.fill
                      : BoxFit.cover,
                ),
              );
            }),
    );
  }
}
