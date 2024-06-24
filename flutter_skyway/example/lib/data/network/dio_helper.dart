import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_interceptors.dart';

abstract class DioHelper {
  static Dio configApiDio({
    required Dio dio,
  }) {
    final options = BaseOptions(
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 10000),
      contentType: "application/json; charset=utf-8",
    );

    dio.options = options;

    dio.interceptors.addAll([
      ApiInterceptors(),
    ]);

    // Logger
    if (kDebugMode) {
      dio.interceptors.add(_DebugLogger());
    }

    return dio;
  }
}

class _DebugLogger extends PrettyDioLogger {
  _DebugLogger()
      : super(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: true,
          maxWidth: 1000,
        );
}
