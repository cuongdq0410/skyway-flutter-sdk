import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skyway_example/data/storage/session_utils.dart';
import 'package:flutter_skyway_example/injection/injector.dart';
import 'package:flutter_skyway_example/ui/widget/app_navigator.dart';
import 'package:flutter_skyway_example/ui/widget/route_define.dart';

class ApiInterceptors extends InterceptorsWrapper {
  final String auth = 'Authorization';
  final String bearer = 'Bearer';

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = SessionUtils.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    // if (response.statusCode == HttpStatus.unauthorized) {
    //   final result = await refreshToken();
    //   if (result) {
    //     return handler.resolve(await _retry(response.requestOptions, response));
    //   }
    // }
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response != null) {
      unAuthorize(err.response!);
    }
    super.onError(err, handler);
  }

  Future<bool> refreshToken() async {
    // final String refreshToken = SessionUtils.getRefreshToken() ?? '';
    // final response = await injector.get<AppApi>().getRefreshToken(refreshToken);
    // if (response.statusCode == HttpStatus.ok) {
    //   SessionUtils.saveAccessToken(response.data);
    //   return true;
    // } else {
    //   SessionUtils.clearSession();
    //   return false;
    // }
    return true;
  }

  Future<Response<dynamic>> retry(
    RequestOptions requestOptions,
    Response response,
  ) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    try {
      return injector.get<Dio>().request<dynamic>(
            requestOptions.baseUrl + requestOptions.path,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
            options: options,
          );
    } on Exception catch (_) {
      return response;
    }
  }

  void unAuthorize(Response response) {
    if (response.statusCode == HttpStatus.unauthorized) {
      SessionUtils.clearSession();
      if (AppNavigator.currentContext == null) return;
      Navigator.pushNamedAndRemoveUntil(
        AppNavigator.currentContext!,
        RouteDefine.loginScreen.name,
        (Route<dynamic> route) => false,
      );
    }
  }
}
