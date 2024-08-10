import 'package:ecostep/presentation/controllers/onboarding_artboard_controller.dart';
import 'package:ecostep/presentation/utils/adaptive_policy.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
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
    with TickerProviderStateMixin {
  // spam click protection
  bool inTransition = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    ref
        .read(onboardingArtboardControllerProvider.notifier)
        .loadRiveFile(isSmallScreen: AdaptivePolicy.isMobile());

    // enable the tap after 3 seconds initially
    Future.delayed(const Duration(seconds: 3), () {
      inTransition = false;
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
    super.initState();
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
      child: SafeArea(
        child: Scaffold(
          backgroundColor: _bgColor(controller.pageNo),
          body: artboard == null
              ? const SizedBox()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (isMobileScreen(context) &&
                        artboard.name.contains('Large')) {
                      controller.loadRiveFile(isSmallScreen: true);
                    } else if (!isMobileScreen(context) &&
                        artboard.name.contains('Small')) {
                      controller.loadRiveFile();
                    }
                    return GestureDetector(
                      onTap: () async {
                        if (!inTransition) {
                          inTransition = true;
                          await controller.animateToNextPage(
                            isSmallScreen: isMobileScreen(context),
                          );
                          Future.delayed(const Duration(seconds: 3), () {
                            inTransition = false;
                          });
                        }
                      },
                      child: Stack(
                        children: [
                          Rive(
                            artboard: artboard,
                            fit: _decideFit(constraints),
                          ),
                          if (controller.pageNo == 3) const GetStartedButton(),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  BoxFit _decideFit(BoxConstraints constraints) {
    if (constraints.maxWidth > 980) {
      return BoxFit.cover;
    }

    if (constraints.maxWidth > 600) {
      return BoxFit.contain;
    }

    return BoxFit.fill;
  }

  Color _bgColor(int pageNo) {
    if (pageNo == 2) return AppColors.treeBarkColor;
    if (pageNo == 3) return AppColors.backgroundColor;
    return Colors.white;
  }
}
