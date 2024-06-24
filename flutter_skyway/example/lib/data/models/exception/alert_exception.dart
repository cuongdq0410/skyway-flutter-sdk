import 'package:flutter_skyway_example/data/models/annotation/exception_type.dart';
import 'package:flutter_skyway_example/data/models/exception/base_exception.dart';

class AlertException extends BaseException {
  String? title;

  AlertException(int code, String message, {this.title})
      : super(code, message, ExceptionType.alert);
}
