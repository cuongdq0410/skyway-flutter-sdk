import 'package:bloc/bloc.dart';
import 'package:flutter_skyway_example/data/network/network_extensions.dart';
import 'package:flutter_skyway_example/data/repository/auth_repository_impl.dart';
import 'package:flutter_skyway_example/data/responses/room_list_response.dart';
import 'package:flutter_skyway_example/data/storage/session_utils.dart';
import 'package:flutter_skyway_example/main.dart';
import 'package:flutter_skyway_example/ui/base/cubit_mixin.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> with CubitMixin {
  HomeCubit() : super(HomeInitial()) {}

  final AuthRepositoryImpl repo = AuthRepositoryImpl();
  List<RoomItemResponse> rooms = [];

  Future<void> getRooms() async {
    final floorId = (SessionUtils.getUser()?.floorId ?? '').toString();
    await repo.getRooms(floorId).easyCompose(
      (response) {
        hideLoading();
        rooms = response.data ?? [];
        emit(GetRoomSuccessState());
      },
      onError: (error) {
        hideLoading();
        setThrowable(error);
      },
    );
  }

  Future<void> getSkywayToken(RoomItemResponse room) async {
    setLoading();
    await repo.getSkywayToken().easyCompose(
      (response) {
        hideLoading();
        emit(
          GetSkywayTokenSuccessState(
            AuthenticationData(
              response.data?.token ?? '',
              DateTime.now().millisecondsSinceEpoch.toString(),
              room,
            ),
          ),
        );
      },
      onError: (error) {
        hideLoading();
        setThrowable(error);
      },
    );
  }
}
