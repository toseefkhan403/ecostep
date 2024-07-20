import 'package:ecostep/application/firebase_auth_service.dart';
import 'package:ecostep/application/firestore_service.dart';
import 'package:ecostep/domain/user.dart';
import 'package:ecostep/presentation/controllers/onboarding_artboard_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neopop/neopop.dart';

class GetStartedButton extends ConsumerStatefulWidget {
  const GetStartedButton({super.key});

  @override
  ConsumerState createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends ConsumerState<GetStartedButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 4),
    reverseDuration: const Duration(seconds: 1),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );
  bool _isVisible = false;
  bool _showLoginButtons = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        _isVisible = true;
      });
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(onboardingArtboardControllerProvider.notifier);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _animation,
          axis: Axis.horizontal,
          axisAlignment: -1,
          child: Opacity(
            opacity: _isVisible ? 1.0 : 0.0,
            child: Center(
              child: _showLoginButtons
                  ? loginButtons()
                  : NeoPopButton(
                      color: AppColors.primaryColor,
                      onTapUp: () {
                        _controller.reverse().then((_) {
                          controller.getStarted();
                          setState(() {
                            _showLoginButtons = true;
                          });
                          _controller
                            ..reset()
                            ..forward();
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 80.w,
                          vertical: 15.h,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget loginButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NeoPopButton(
          color: AppColors.primaryColor,
          onTapUp: () async {
            final user =
                await ref.read(firebaseAuthServiceProvider).signInWithGoogle();
            if (user == null) return;

            await ref.read(firestoreServiceProvider).createUserIfDoesntExist(
                  User(
                    id: user.uid,
                    ecoBucksBalance: 100,
                    personalization: false,
                    name: user.displayName,
                    profilePicture: user.photoURL,
                    impactScore: 0,
                    joinedOn: DateTime.now(),
                  ),
                );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 80.w,
              vertical: 15.h,
            ),
            child: const Text(
              'Sign in with Google',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        NeoPopButton(
          color: AppColors.primaryColor,
          onTapUp: () async {
            final user =
                await ref.read(firebaseAuthServiceProvider).signInAnonymously();
            if (user == null) return;

            await ref.read(firestoreServiceProvider).createUserIfDoesntExist(
                  User(
                    id: user.uid,
                    ecoBucksBalance: 100,
                    personalization: false,
                    name: user.displayName,
                    profilePicture: user.photoURL,
                    impactScore: 0,
                    joinedOn: DateTime.now(),
                  ),
                );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 80.w,
              vertical: 15.h,
            ),
            child: const Text(
              ' Sign in as a Guest  ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
