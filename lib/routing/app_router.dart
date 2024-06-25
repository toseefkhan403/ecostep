import 'package:ecostep/presentation/pages/home_screen.dart';
import 'package:ecostep/presentation/pages/onboarding_page.dart';
import 'package:ecostep/presentation/pages/unknown_page.dart';
import 'package:ecostep/routing/app_routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: AppRoute.onboarding.name,
        builder: (context, state) {
          return const OnboardingPage();
        },
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (context, state) {

          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/unknown',
        name: AppRoute.unknown.name,
        builder: (context, state) => const UnknownPage(),
      ),
    ],
    errorBuilder: (context, state) => const UnknownPage(),
    initialLocation: '/',
    debugLogDiagnostics: true,
    observers: [
      // FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
  );
}
