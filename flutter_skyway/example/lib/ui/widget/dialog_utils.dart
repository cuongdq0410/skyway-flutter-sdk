import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_navigator.dart';
import 'toast_message/toast_message.dart';

class DialogUtils {
  static Widget? commonLoadingWidget;

  static void hideLoading({BuildContext? context}) {
    final buildContext = context ?? AppNavigator.currentContext;
    if (buildContext == null) return;
    buildContext.hideLoading();
  }

  static void showLoading(
      {BuildContext? context, Widget? customLoadingWidget}) {
    final buildContext = context ?? AppNavigator.currentContext;
    if (buildContext == null) return;
    buildContext.showLoading();
  }

  static showAlert(
    BuildContext? context, {
    ToastMessageType toastMessageType = ToastMessageType.error,
    required String message,
  }) {
    final buildContext = context ?? AppNavigator.currentContext;
    if (buildContext == null) return;
    buildContext.showToastMessage(message, toastMessageType);
  }

  static Future<T?> showCustomBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    BoxConstraints? constraints,
    Color? barrierColor,
  }) {
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      barrierColor: barrierColor,
      constraints: constraints,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
          child: Material(
            color: Colors.white,
            child: child,
          ),
        );
      },
    );
  }

  static Future<T?> showCustomDialog<T>(
    Widget dialog, {
    BuildContext? context,
    bool barrierDismissible = true,
    bool useSafeArea = true,
  }) {
    return showDialog(
      barrierColor: Colors.black26,
      context: context ?? AppNavigator.currentContext!,
      barrierDismissible: barrierDismissible,
      useSafeArea: useSafeArea,
      builder: (context) {
        return dialog;
      },
    );
  }
}
