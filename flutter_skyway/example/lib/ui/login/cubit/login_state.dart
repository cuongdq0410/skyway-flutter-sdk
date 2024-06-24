part of 'login_cubit.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {}

class LoginErrorState extends LoginState {}

class ContinueButtonStatusState extends LoginState {}

class LoginButtonStatusState extends LoginState {}

class ExpireOtpTime extends LoginState {}

class ValidOtpTime extends LoginState {}

class PassLoginButtonStatusState extends LoginState {}

class GetOtpSuccess extends LoginState {
  final String phoneNumber;
  final String token;

  GetOtpSuccess({required this.phoneNumber, required this.token});
}

class VerifyOtpSuccess extends LoginState {}
