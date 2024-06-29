import 'package:ecostep/presentation/utils/adaptive_policy.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// 6 weeks to finish - lead with web
// week 1(24 June) - complete onboarding - rive design, animation, text, coding - done
// week 2(1 July) - questionnaire, user auth, firebase setup, leaderboard and profile page
// week 3(8 July) - daily tasks feature - ai gen, parse and display, scoring system, and verification feature
// week 4(15 July) - marketplace feature - upload stuff, list it, buy it, transactions, your orders in settings
// week 5(22 July) - slick video, sound fx and apple account setup(if needed)
// week 6(29 July) - responsiveness and release
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AdaptivePolicy.init();
  setUrlStrategy(PathUrlStrategy());
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
