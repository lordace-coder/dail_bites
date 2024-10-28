import 'package:flutter/material.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();

  factory AppRouter() {
    return _instance;
  }

  AppRouter._internal();

  /// Global key for navigation
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a new screen
  Future<T?> navigateTo<T>(Widget screen, {bool replace = false}) async {
    if (replace) {
      return await navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => screen),
      );
    }
    return await navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Navigate and remove all previous screens
  Future<T?> navigateAndRemoveUntil<T>(Widget screen) async {
    return await navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  /// Pop the current screen
  void pop<T>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop(result);
    }
  }

  /// Pop until a specific route name
  void popUntil(String routeName) {
    navigatorKey.currentState?.popUntil(ModalRoute.withName(routeName));
  }

  /// Check if can pop
  bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  /// Navigate with custom transition
  Future<T?> navigateWithTransition<T>(
    Widget screen, {
    Duration duration = const Duration(milliseconds: 300),
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return await navigatorKey.currentState?.push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: duration,
        transitionsBuilder: transition ??
            (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
      ),
    );
  }
}


/*
// Navigate to a new screen
NavigationHelper().navigateTo(HomeScreen());

// Replace current screen
NavigationHelper().navigateTo(LoginScreen(), replace: true);

// Navigate and remove all previous screens (useful for login/logout)
NavigationHelper().navigateAndRemoveUntil(WelcomeScreen());

// Navigate with custom transition
NavigationHelper().navigateWithTransition(
  DetailsScreen(),
  duration: Duration(milliseconds: 500),
  transition: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
);

// Go back
NavigationHelper().pop();
 */