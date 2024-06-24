import 'package:flutter_skyway_example/data/app_error.dart';
import 'package:flutter_skyway_example/data/network/app_api.dart';
import 'package:flutter_skyway_example/data/network/exception_mapper.dart';
import 'package:flutter_skyway_example/data/requests/login_request.dart';
import 'package:flutter_skyway_example/data/responses/login_response.dart';
import 'package:flutter_skyway_example/data/responses/room_list_response.dart';
import 'package:flutter_skyway_example/data/responses/skyway_token_response.dart';
import 'package:flutter_skyway_example/data/storage/session_utils.dart';
import 'package:flutter_skyway_example/injection/injector.dart';

class AuthRepositoryImpl {
  static final AppApi api = injector<AppApi>();

  Future<LoginResponse> login(LoginRequest request) async {
    final data = await api.login(request).catchError((error, stackTrace) async {
      throw await injector
          .get<ExceptionMapper>()
          .mapperTo(AppError.from(error as Exception));
    });
    if (data.data?.accessToken != null) {
      SessionUtils.saveAccessToken(data.data!.accessToken!);
    }
    if (data.data?.user != null) {
      SessionUtils.saveUser(data.data!.user!);
    }
    return data;
  }

  Future<RoomListResponse> getRooms(String floorId) async {
    return api.getRooms(floorId).catchError((error, stackTrace) async {
      throw await injector
          .get<ExceptionMapper>()
          .mapperTo(AppError.from(error as Exception));
    });
  }

  Future<SkywayTokenResponse> getSkywayToken() async {
    return api.getSkywayToken().catchError((error, stackTrace) async {
      throw await injector
          .get<ExceptionMapper>()
          .mapperTo(AppError.from(error as Exception));
    });
  }
}
