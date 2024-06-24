import 'package:json_annotation/json_annotation.dart';

part 'api_base_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  StatusResponse? status;
  T? data;

  ApiResponse({this.status, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson<T>(json, fromJsonT);
}

@JsonSerializable()
class StatusResponse {
  int? code;
  String? header;
  String? message;

  StatusResponse({this.code, this.header, this.message});

  factory StatusResponse.fromJson(Map<String, dynamic> json) =>
      _$StatusResponseFromJson(json);
}
