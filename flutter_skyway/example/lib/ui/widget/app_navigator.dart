import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum NavigatorStackAction {
  /// Keep all of stacks
  keep,

  /// Replace last stack
  replace,

  /// Remove all stacks
  removeAll,
}

class AppNavigator {
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Get context.
  ///
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate
  static Future<dynamic> navigateTo(
    BuildContext context,
    String routeName, {
    dynamic arguments,
    NavigatorStackAction? stackAction = NavigatorStackAction.keep,
  }) async {
    switch (stackAction) {
      case NavigatorStackAction.replace:
        return Navigator.pushReplacementNamed(
          context,
          routeName,
          arguments: arguments,
        );
      case NavigatorStackAction.removeAll:
        return Navigator.pushNamedAndRemoveUntil(
          context,
          routeName,
          (route) => false,
          arguments: arguments,
        );
      default:
        return Navigator.pushNamed(
          context,
          routeName,
          arguments: arguments,
        );
    }
  }

  /// Goes back to previous screen.
  ///
  static void goBack({
    dynamic arguments,
  }) {
    final currentState = navigatorKey.currentState;
    if (currentState == null) {
      return;
    }
    return currentState.pop(arguments);
  }

  /// Get can go back status.
  ///
  static bool get canGoBack {
    final currentState = navigatorKey.currentState;
    if (currentState == null) {
      return false;
    }
    return currentState.canPop();
  }

  /// Removes all the screens on the stack until the given route name
  /// If hasn't given route name it will pop to first screen
  static void popUntil({
    String? routeName,
  }) {
    final currentState = navigatorKey.currentState;
    if (currentState == null) {
      return;
    }

    if (routeName != null) {
      final isCurrent = _isCurrent(
        routeName,
        currentState,
      );
      if (!isCurrent) {
        currentState.popUntil((route) => route.settings.name == routeName);
      }
    } else {
      currentState.popUntil((route) => route.isFirst);
    }
  }

  static bool _isCurrent(
    String routeName,
    NavigatorState currentState,
  ) {
    var isCurrent = false;

    currentState.popUntil((route) {
      if (route.settings.name == routeName) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }
}
