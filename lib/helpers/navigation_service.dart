import 'package:flutter/material.dart';

/// A simple navigation service using a global [navigatorKey].
///
/// This class provides static helper methods for navigation throughout the app.
/// It is deliberately lightweight and does not depend on any other
/// project files, so it can be imported anywhere (e.g., UIHelper).
class NavigationService {
  // Private singleton instance.
  static final NavigationService _navigationService =
      NavigationService._internal();
  NavigationService._internal();

  /// Public accessor for the singleton.
  static NavigationService get instance => _navigationService;

  /// Global key used by the app's MaterialApp.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Navigate to a named route.
  static Future<dynamic> navigateTo(String routeName) =>
      navigatorKey.currentState?.pushNamed(routeName) ?? Future.value(null);

  /// Replace current route with a named route.
  static Future<dynamic> navigateToReplacement(String routeName) =>
      navigatorKey.currentState?.pushReplacementNamed(routeName) ?? Future.value(null);

  /// Replace current route with a named route and pass an optional argument.
  static Future<dynamic> navigateToReplacementWithObj(
    String routeName,
    Object? obj,
  ) => navigatorKey.currentState?.pushReplacementNamed(
    routeName,
    arguments: obj,
  ) ?? Future.value(null);

  /// Push a new route and remove all previous ones.
  static Future<dynamic> navigateToUntilReplacement(String routeName) =>
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
      ) ?? Future.value(null);

  /// Pop the current route and push a new one.
  static Future<dynamic> popAndReplace(String routeName) async =>
      await navigatorKey.currentState?.popAndPushNamed(routeName) ?? Future.value(null);

  /// Navigate to a route with a map of arguments.
  static Future<dynamic> navigateToWithArgs(
    String routeName,
    Map<String, dynamic>? map,
  ) => navigatorKey.currentState?.pushNamed(routeName, arguments: map) ?? Future.value(null);

  /// Pop the current route and push a new one with arguments.
  static Future<dynamic> popAndReplaceWithArgs(
    String routeName,
    Map<String, dynamic>? map,
  ) => navigatorKey.currentState?.popAndPushNamed(routeName, arguments: map) ?? Future.value(null);

  /// Navigate to a route with a generic object argument.
  static Future<dynamic> navigateToWithObject(String routeName, Object? obj) =>
      navigatorKey.currentState?.pushNamed(routeName, arguments: obj) ?? Future.value(null);

  /// Simple back navigation.
  static void goBack() => navigatorKey.currentState?.pop();

  /// Returns `true` if the navigator can pop.
  static bool get canGoBack => navigatorKey.currentState?.canPop() ?? false;

  /// Current `BuildContext` from the navigator.
  static BuildContext? get context => navigatorKey.currentContext;
}
