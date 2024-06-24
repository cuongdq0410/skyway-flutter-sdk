import 'package:freezed_annotation/freezed_annotation.dart';

part 'skyway_token_response.freezed.dart';
part 'skyway_token_response.g.dart';

@freezed
class SkywayTokenResponse with _$SkywayTokenResponse {
  const factory SkywayTokenResponse({
    @JsonKey(name: 'data') DataBean? data,
  }) = _SkywayTokenResponse;

  factory SkywayTokenResponse.fromJson(Map<String, Object?> json) =>
      _$SkywayTokenResponseFromJson(json);
}

@freezed
class DataBean with _$DataBean {
  const factory DataBean({
    @JsonKey(name: 'token') String? token,
    @JsonKey(name: 'expiration') String? expiration,
  }) = _DataBean;

  factory DataBean.fromJson(Map<String, Object?> json) =>
      _$DataBeanFromJson(json);
}
