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
