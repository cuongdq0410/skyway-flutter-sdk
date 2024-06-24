import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    @JsonKey(name: 'data') DataBean? data,
    @JsonKey(name: 'errors') bool? errors,
    @JsonKey(name: 'message') String? message,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, Object?> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
class DataBean with _$DataBean {
  const factory DataBean({
    @JsonKey(name: 'accessToken') String? accessToken,
    @JsonKey(name: 'refreshToken') String? refreshToken,
    @JsonKey(name: 'socket_id') String? socketId,
    @JsonKey(name: 'user') UserResponse? user,
  }) = _DataBean;

  factory DataBean.fromJson(Map<String, Object?> json) =>
      _$DataBeanFromJson(json);
}

@freezed
class UserResponse with _$UserResponse {
  const factory UserResponse({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'uid') String? uid,
    @JsonKey(name: 'login_id') dynamic loginId,
    @JsonKey(name: 'company_id') int? companyId,
    @JsonKey(name: 'status') int? status,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'code') String? code,
    @JsonKey(name: 'email_verified_at') dynamic emailVerifiedAt,
    @JsonKey(name: 'email_verify_token') dynamic emailVerifyToken,
    @JsonKey(name: 'remember_token') dynamic rememberToken,
    @JsonKey(name: 'onamae') String? onamae,
    @JsonKey(name: 'nick_name') dynamic nickName,
    @JsonKey(name: 'login_status') int? loginStatus,
    @JsonKey(name: 'login_failure_at') dynamic loginFailureAt,
    @JsonKey(name: 'login_failure_count') dynamic loginFailureCount,
    @JsonKey(name: 'comment') String? comment,
    @JsonKey(name: 'avatar') String? avatar,
    @JsonKey(name: 'profile') dynamic profile,
    @JsonKey(name: 'deleted_at') dynamic deletedAt,
    @JsonKey(name: 'created_at') dynamic createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'role') int? role,
    @JsonKey(name: 'is_mic') int? isMic,
    @JsonKey(name: 'is_speaker') int? isSpeaker,
    @JsonKey(name: 'custom_status') dynamic customStatus,
    @JsonKey(name: 'floor_id') int? floorId,
    @JsonKey(name: 'position') String? position,
    @JsonKey(name: 'login_at') String? loginAt,
    @JsonKey(name: 'voice_chat_id') String? voiceChatId,
    @JsonKey(name: 'room_id') int? roomId,
    @JsonKey(name: 'commented_at') dynamic commentedAt,
    @JsonKey(name: 'change_mic_at') String? changeMicAt,
    @JsonKey(name: 'change_speaker_at') String? changeSpeakerAt,
    @JsonKey(name: 'last_write_log') dynamic lastWriteLog,
    @JsonKey(name: 'mic_level') int? micLevel,
    @JsonKey(name: 'speaker_level') int? speakerLevel,
    @JsonKey(name: 'sound_filter') int? soundFilter,
    @JsonKey(name: 'floors') FloorsBean? floors,
    @JsonKey(name: 'companies') CompaniesBean? companies,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, Object?> json) =>
      _$UserResponseFromJson(json);
}

@freezed
class CompaniesBean with _$CompaniesBean {
  const factory CompaniesBean({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'company_code') String? companyCode,
    @JsonKey(name: 'company_name') String? companyName,
  }) = _CompaniesBean;

  factory CompaniesBean.fromJson(Map<String, Object?> json) =>
      _$CompaniesBeanFromJson(json);
}

@freezed
class FloorsBean with _$FloorsBean {
  const factory FloorsBean({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'status') int? status,
    @JsonKey(name: 'name') String? name,
  }) = _FloorsBean;

  factory FloorsBean.fromJson(Map<String, Object?> json) =>
      _$FloorsBeanFromJson(json);
}
