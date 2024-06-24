part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class GetRoomSuccessState extends HomeState {}

class GetSkywayTokenSuccessState extends HomeState {
  GetSkywayTokenSuccessState(this.data);

  final AuthenticationData data;
}
