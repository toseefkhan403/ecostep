import 'package:ecostep/presentation/pages/home_screen.dart';
import 'package:ecostep/presentation/pages/onboarding_page.dart';
import 'package:ecostep/presentation/pages/unknown_page.dart';
import 'package:ecostep/routing/app_routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    initialLocation: '/home',
    // redirect: (context, GoRouterState state) async {
    //   final authState = ref.watch(authStateProvider);

    //   final isLoggedIn = authState.asData?.value != null;
    //   print('isLogged in: $isLoggedIn');
    //   final isLoggingIn = state.matchedLocation == '/';
    //   if (!isLoggedIn && !isLoggingIn) return '/';
    //   if (isLoggedIn && isLoggingIn) return '/home';
    //   return null;
    // },
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
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionDuration: const Duration(milliseconds: 1000),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/unknown',
        name: AppRoute.unknown.name,
        builder: (context, state) => const UnknownPage(),
      ),
    ],
    errorBuilder: (context, state) => const UnknownPage(),
    debugLogDiagnostics: true,
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
  );
}
