import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_skyway_example/data/network/network_extensions.dart';
import 'package:flutter_skyway_example/data/repository/auth_repository_impl.dart';
import 'package:flutter_skyway_example/data/requests/login_request.dart';
import 'package:flutter_skyway_example/ui/base/cubit_mixin.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> with CubitMixin {
  LoginCubit() : super(LoginInitial());
  final AuthRepositoryImpl repo = AuthRepositoryImpl();

  Future login(
    String email,
    String password,
  ) async {
    setLoading();
    await repo
        .login(
      LoginRequest(
        email: email,
        password: password,
      ),
    )
        .easyCompose(
      (response) {
        hideLoading();
        emit(LoginSuccessState());
      },
      onError: (error) {
        hideLoading();
        setThrowable(error);
        emit(LoginErrorState());
      },
    );
  }
}
