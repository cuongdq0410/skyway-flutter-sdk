import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
@JsonSerializable()
class LoginRequest {
  @JsonKey(name: 'email')
  String email;
  @JsonKey(name: 'password')
  String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
