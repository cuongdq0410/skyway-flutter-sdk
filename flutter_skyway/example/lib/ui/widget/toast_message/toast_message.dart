import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'widgets/in_app_notification.dart';

enum ToastMessageType {
  success,
  warning,
  error,
}

extension ShowToastExt on State<StatefulWidget> {
  void showToastMessage(String message,
      [ToastMessageType type = ToastMessageType.success]) {
    _showToastMessage(context, message, type);
  }

  void showLoading() {
    BotToast.showLoading();
  }

  void hideLoading() {
    BotToast.closeAllLoading();
  }

  void showToastText(String text) {
    BotToast.showText(text: text);
  }
}

typedef ToastBuilder = Widget Function(BuildContext, Widget?);

final ToastBuilder toastBuilder = BotToastInit();

extension BuctxLoading on BuildContext {
  void showToastText(String text) {
    BotToast.showText(text: text);
  }

  void showLoading() {
    BotToast.showLoading();
  }

  void hideLoading() {
    BotToast.closeAllLoading();
  }

  void showToastMessage(String message,
      [ToastMessageType type = ToastMessageType.success]) {
    _showToastMessage(this, message, type);
  }
}

void _showToastMessage(BuildContext context, String message,
    [ToastMessageType type = ToastMessageType.success]) {
  var colorBg = Theme.of(context).scaffoldBackgroundColor;
  var icon = Icon(
    CupertinoIcons.checkmark_circle,
    color: Colors.black,
    size: 24.sp,
  );

  switch (type) {
    case ToastMessageType.success:
      colorBg = Colors.white;
      icon = Icon(
        CupertinoIcons.checkmark_circle_fill,
        color: const Color(0xff209653),
        size: 24.sp,
      );
      break;
    case ToastMessageType.warning:
      colorBg = Colors.amber[400]!;
      icon = Icon(
        CupertinoIcons.info,
        color: Colors.white,
        size: 24.sp,
      );
      break;
    case ToastMessageType.error:
      colorBg = const Color(0xffff5252);
      icon = Icon(
        Icons.error,
        color: Colors.white,
        size: 24.sp,
      );
      break;
  }
  final overlayState = Overlay.of(context);
  showTopSnackBar(
    overlayState,
    InAppNotificationWidget(
      text: message,
      colorBackground: colorBg,
      icon: icon,
      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ToastMessageType.success == type ? null : Colors.white,
          ),
    ),
    displayDuration: const Duration(milliseconds: 2000),
  );
}
