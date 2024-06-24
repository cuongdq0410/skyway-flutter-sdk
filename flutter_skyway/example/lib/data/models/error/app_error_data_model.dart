import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'error_data_model.dart';

part 'app_error_data_model.freezed.dart';
part 'app_error_data_model.g.dart';

AppErrorDataModel appErrorDataModelFromJson(String str) =>
    AppErrorDataModel.fromJson(json.decode(str) as Map<String, dynamic>);

String appErrorDataModelToJson(AppErrorDataModel data) =>
    json.encode(data.toJson());

@freezed
class AppErrorDataModel with _$AppErrorDataModel {
  const factory AppErrorDataModel({
    int? statusCode,
    List<dynamic>? data,
    String? message,
  }) = _AppErrorDataModel;

  factory AppErrorDataModel.fromJson(Map<String, dynamic> json) =>
      _$AppErrorDataModelFromJson(json);
}

@freezed
class Errors with _$Errors {
  const factory Errors({
    List<String>? input,
  }) = _Errors;

  factory Errors.fromJson(Map<String, dynamic> json) => _$ErrorsFromJson(json);
}

extension AppErrorDataModelExt on AppErrorDataModel {
  ErrorDataModel toErrorDataModel() => ErrorDataModel(
        errorCode: statusCode,
        message: message,
      );
}
