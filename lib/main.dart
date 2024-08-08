// ignore_for_file: lines_longer_than_80_chars

import 'package:ecostep/configure_nonweb.dart'
    if (dart.library.html) 'configure_web.dart';
import 'package:ecostep/firebase_options.dart';
import 'package:ecostep/presentation/utils/adaptive_policy.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/routing/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

// 6 weeks to finish - lead with web
// week 1(24 June) - complete onboarding - rive design, animation, text, coding - done
// week 2(1 July) - questionnaire, user auth, firebase setup, leaderboard and profile page --done
// week 3(8 July) - daily tasks feature - ai gen, parse and display, scoring system, and verification feature, store user in firestore
// week 4(15 July) - marketplace feature - upload stuff, list it, buy it, your orders in profile
// week 5(22 July) - transactions, slick video, sound fx and apple account setup(if needed)
// week 6(29 July) - responsiveness and release

// finalize video
// fix post image issue - done
// sounds not working in web - done
// add spam protection on login buttons - done
// fix android sign in issue - done
// update web metadata in index.html, favicon - done
// fix select image showing in verified dialog - done
// add camera option with warning for gallery option - done
// profile page changes - done
// responsiveness in android
// responsiveness in starting rive animation
// add download from play store button in profile page
// fix fragile leaderboard page
// show profile page on leaderboard card tap
// build for web, windows, android, ios, linux
// try storing chat history in a file for gemini
// update github
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureApp();
  AdaptivePolicy.init();
  await dotenv.load();
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
    return ToastificationWrapper(
      child: MaterialApp.router(
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
      ),
    );
  }
}
