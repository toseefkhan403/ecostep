import 'package:ecostep/application/audio_player_service.dart';
import 'package:ecostep/application/firebase_auth_service.dart';
import 'package:ecostep/application/username_generator.dart';
import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/domain/date.dart';
import 'package:ecostep/domain/user.dart';
import 'package:ecostep/presentation/controllers/onboarding_artboard_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool _isProcessing = false;

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
                  : Semantics(
                      label: 'Get Started',
                      child: NeoPopButton(
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
                          ref.read(audioPlayerServiceProvider).playClickSound();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 15,
                          ),
                          child: Text(
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
        Semantics(
          label: 'Google sign in',
          child: NeoPopButton(
            color: AppColors.primaryColor,
            onTapUp: _isProcessing ? null : _handleSignInWithGoogle,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 80,
                vertical: 15,
              ),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          label: 'Sign in as a Guest',
          child: NeoPopButton(
            color: AppColors.primaryColor,
            onTapUp: _isProcessing ? null : _handleSignInAnonymously,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 80,
                vertical: 15,
              ),
              child: Text(
                ' Sign in as a Guest  ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignInWithGoogle() async {
    if (_isProcessing) return;

    try {
      final user =
          await ref.read(firebaseAuthServiceProvider).signInWithGoogle();
      if (user == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      await ref.read(userRepositoryProvider).createUserIfDoesntExist(
            User(
              id: user.uid,
              ecoBucksBalance: 100,
              name: user.displayName ?? _randomUsername(),
              profilePicture: user.photoURL,
              streak: 0,
              joinedOn: Date.today().toString(),
            ),
          );
      await ref.read(audioPlayerServiceProvider).playClickSound();
    } catch (e) {
      // debugPrint(e.toString());
    }
  }

  Future<void> _handleSignInAnonymously() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      final user =
          await ref.read(firebaseAuthServiceProvider).signInAnonymously();
      if (user == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      debugPrint('user authenticated ${user.uid}');
      await ref.read(userRepositoryProvider).createUserIfDoesntExist(
            User(
              id: user.uid,
              ecoBucksBalance: 100,
              name: user.displayName ?? _randomUsername(),
              profilePicture: user.photoURL,
              streak: 0,
              joinedOn: Date.today().toString(),
            ),
          );
      await ref.read(audioPlayerServiceProvider).playClickSound();
    } catch (e) {
      // debugPrint(e.toString());
    }
  }

  String _randomUsername() => UsernameGenerator().generateUsername();
}
