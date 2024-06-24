import 'package:freezed_annotation/freezed_annotation.dart';

part 'common_api_response.freezed.dart';

part 'common_api_response.g.dart';

@freezed
class CommonApiResponse with _$CommonApiResponse {
  const factory CommonApiResponse({
    @Default(false) @JsonKey(name: 'alert') bool? alert,
    @JsonKey(name: 'content') String? content,
  }) = _CommonApiResponse;

  factory CommonApiResponse.fromJson(Map<String, Object?> json) =>
      _$CommonApiResponseFromJson(json);
}
