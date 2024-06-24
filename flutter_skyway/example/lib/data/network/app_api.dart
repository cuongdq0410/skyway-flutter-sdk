import 'package:dio/dio.dart';
import 'package:flutter_skyway_example/data/requests/login_request.dart';
import 'package:flutter_skyway_example/data/responses/login_response.dart';
import 'package:flutter_skyway_example/data/responses/room_list_response.dart';
import 'package:flutter_skyway_example/data/responses/skyway_token_response.dart';
import 'package:retrofit/retrofit.dart';

part 'app_api.g.dart';

@RestApi()
abstract class AppApi {
  factory AppApi(Dio dio, {String baseUrl}) = _AppApi;

  @POST("/login")
  Future<LoginResponse> login(@Body() LoginRequest loginRequest);

  @GET('/rooms/active/{id}')
  Future<RoomListResponse> getRooms(@Path('id') String roomId);

  @GET("/skyway/token")
  Future<SkywayTokenResponse> getSkywayToken();
}
