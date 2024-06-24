import 'package:dio/dio.dart';
import 'package:flutter_skyway_example/data/network/app_api.dart';
import 'package:flutter_skyway_example/data/network/dio_helper.dart';
import 'package:flutter_skyway_example/data/network/exception_mapper.dart';
import 'package:flutter_skyway_example/data/storage/shared_pref_manager.dart';
import 'package:flutter_skyway_example/injection/injector.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/socket/socket_service.dart';

class DataModules {
  static Future<void> inject() async {
    injector.registerLazySingleton<Dio>(
      Dio.new,
    );
    DioHelper.configApiDio(dio: injector.get<Dio>());

    /// Local storage
    injector
      ..registerSingletonAsync<SharedPreferences>(() async {
        return SharedPreferences.getInstance();
      })
      ..registerLazySingleton<SharedPreferencesManager>(
        () => SharedPreferencesManager(injector.get<SharedPreferences>()),
      )

      /// Network client
      ..registerLazySingleton<AppApi>(
        () => AppApi(
          injector.get<Dio>(),
          baseUrl: 'https://routes-dev.voichat.com/v2',
        ),
      )

      ///Socket
      ..registerLazySingleton<SocketService>(
        SocketService.new,
      )
      ..registerFactory<ExceptionMapper>(
        ExceptionMapper.new,
      );
  }
}
