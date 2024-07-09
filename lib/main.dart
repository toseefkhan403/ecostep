// ignore_for_file: lines_longer_than_80_chars

import 'package:ecostep/configure_nonweb.dart'
    if (dart.library.html) 'configure_web.dart';
import 'package:ecostep/firebase_options.dart';
import 'package:ecostep/presentation/utils/adaptive_policy.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/routing/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 6 weeks to finish - lead with web
// week 1(24 June) - complete onboarding - rive design, animation, text, coding - done
// week 2(1 July) - questionnaire, user auth, firebase setup, leaderboard and profile page --done
// week 3(8 July) - daily tasks feature - ai gen, parse and display, scoring system, and verification feature
// week 4(15 July) - marketplace feature - upload stuff, list it, buy it, transactions, your orders in settings
// week 5(22 July) - slick video, sound fx and apple account setup(if needed)
// week 6(29 July) - responsiveness and release
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdaptivePolicy.init();
  configureApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: GreenLoopApp()));
}

class GreenLoopApp extends ConsumerWidget {
  const GreenLoopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return ScreenUtilInit(
      designSize: AdaptivePolicy.getDesignSize(),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp.router(
          routerConfig: goRouter,
          title: 'GreenLoop',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryColor,
            ),
            useMaterial3: true,
            fontFamily: 'Poppins',
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
