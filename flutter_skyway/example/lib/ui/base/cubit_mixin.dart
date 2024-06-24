import 'package:flutter_skyway_example/data/models/annotation/exception_type.dart';
import 'package:flutter_skyway_example/data/models/exception/alert_exception.dart';
import 'package:flutter_skyway_example/data/models/exception/base_exception.dart';
import 'package:flutter_skyway_example/data/models/exception/inline_exception.dart';
import 'package:flutter_skyway_example/data/models/exception/toast_exception.dart';
import 'package:flutter_skyway_example/ui/widget/app_navigator.dart';
import 'package:flutter_skyway_example/ui/widget/dialog_utils.dart';

mixin CubitMixin {
  void setLoading() {
    DialogUtils.showLoading();
  }

  void hideLoading() {
    DialogUtils.hideLoading();
  }

  void setThrowable(dynamic throwable) {
    if (throwable is BaseException) {
      switch (throwable.exceptionType) {
        case ExceptionType.toast:
          final e = throwable as ToastException;
          DialogUtils.showAlert(
            AppNavigator.currentContext,
            message: e.message,
          );
        case ExceptionType.alert:
          final e = throwable as AlertException;
          DialogUtils.showAlert(
            AppNavigator.currentContext,
            message: e.message,
          );
        case ExceptionType.inline:
          final e = throwable as InlineException;
          DialogUtils.showAlert(
            AppNavigator.currentContext,
            message: e.message,
          );
      }
    } else {
      DialogUtils.showAlert(
        AppNavigator.currentContext,
        message: 'Error',
      );
    }
  }
}
