import 'package:flutter_skyway_example/data/models/annotation/exception_type.dart';
import 'package:flutter_skyway_example/data/models/annotation/tag.dart';
import 'package:flutter_skyway_example/data/models/exception/base_exception.dart';

class InlineException extends BaseException {
  final List<Tag> tags;

  InlineException(int code, String message, {required this.tags})
      : super(code, message, ExceptionType.inline);
}
