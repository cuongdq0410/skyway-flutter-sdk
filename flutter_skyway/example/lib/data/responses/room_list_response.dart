import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_list_response.freezed.dart';
part 'room_list_response.g.dart';

@freezed
class RoomListResponse with _$RoomListResponse {
  const factory RoomListResponse({
    @JsonKey(name: 'data') List<RoomItemResponse>? data,
  }) = _RoomListResponse;

  factory RoomListResponse.fromJson(Map<String, Object?> json) =>
      _$RoomListResponseFromJson(json);
}

@freezed
class RoomItemResponse with _$RoomItemResponse {
  const factory RoomItemResponse({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'floor_id') int? floorId,
    @JsonKey(name: 'status') int? status,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'view_no') int? viewNo,
    @JsonKey(name: 'created_user') int? createdUser,
    @JsonKey(name: 'updated_user') int? updatedUser,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'room_icon_id') int? roomIconId,
    @JsonKey(name: 'company_id') int? companyId,
  }) = _RoomItemResponse;

  factory RoomItemResponse.fromJson(Map<String, Object?> json) =>
      _$RoomItemResponseFromJson(json);
}
