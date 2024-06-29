import 'package:ecostep/presentation/controllers/onboarding_artboard_controller.dart';
import 'package:ecostep/presentation/utils/adaptive_policy.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/get_started_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with SingleTickerProviderStateMixin {
  // spam click protection
  bool inTransition = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    ref
        .read(onboardingArtboardControllerProvider.notifier)
        .loadRiveFile(isSmallScreen: AdaptivePolicy.isMobile());

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(onboardingArtboardControllerProvider.notifier);
    final artboard = ref.watch(onboardingArtboardControllerProvider);

    return FadeTransition(
      opacity: _animation,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: artboard == null
            ? const SizedBox()
            : LayoutBuilder(builder: (context, constraints) {
                if (isMobileScreen(context) &&
                    artboard.name.contains("Large")) {
                  controller.loadRiveFile(isSmallScreen: true);
                } else if (!isMobileScreen(context) &&
                    artboard.name.contains("Small")) {
                  controller.loadRiveFile(isSmallScreen: false);
                }
                return GestureDetector(
                  onTap: () async {
                    if (!inTransition) {
                      inTransition = true;
                      await controller.animateToNextPage(
                          isSmallScreen: isMobileScreen(context));
                      Future.delayed(const Duration(seconds: 3), () {
                        inTransition = false;
                      });
                    }
                  },
                  child: Stack(
                    children: [
                      Rive(
                        artboard: artboard,
                        fit: artboard.name.contains("Small")
                            ? BoxFit.fill
                            : BoxFit.cover,
                      ),
                      if (controller.pageNo == 3) const GetStartedButton(),
                    ],
                  ),
                );
              }),
      ),
    );
  }
}
