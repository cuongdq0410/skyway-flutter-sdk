import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skyway/flutter_skyway.dart';
import 'package:flutter_skyway_example/data/socket/socket_service.dart';
import 'package:flutter_skyway_example/data/storage/session_utils.dart';
import 'package:flutter_skyway_example/main.dart';
import 'package:flutter_skyway_example/ui/base/base_screen.dart';
import 'package:flutter_skyway_example/ui/call_room/ui/call_page.dart';
import 'package:flutter_skyway_example/ui/home/cubit/home_cubit.dart';
import 'package:flutter_skyway_example/ui/widget/app_navigator.dart';
import 'package:flutter_skyway_example/ui/widget/route_define.dart';
import 'package:flutter_skyway_example/ui/widget/toast_message/toast_message.dart';
import 'package:flutter_skyway_platform_interface/flutter_skyway_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../injection/injector.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen, HomeCubit> {
  @override
  afterBuild() {
    cubit.getRooms();
    injector<SocketService>().connect();
    SkyWay.onJoinCallStream().listen((event) {
      if (event == JoinCallEvent.joining) {
        context.showLoading();
      }
      if (event == JoinCallEvent.joinSuccess) {
        context.hideLoading();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CallPage()),
        );
      }
      if (event == JoinCallEvent.joinFail) {
        context.hideLoading();
      }
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox(),
        actions: [
          IconButton(
            onPressed: () {
              SessionUtils.clearSession().then(
                (value) {
                  AppNavigator.navigateTo(
                    context,
                    RouteDefine.loginScreen.name,
                    stackAction: NavigatorStackAction.removeAll,
                  );
                },
              );
            },
            icon: const Icon(
              color: Colors.red,
              Icons.logout_rounded,
            ),
          )
        ],
      ),
      body: BlocConsumer(
        bloc: cubit,
        listener: (context, state) {
          if (state is GetSkywayTokenSuccessState) {
            onConnect(state.data);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              await cubit.getRooms();
            },
            child: ListView.builder(
              itemCount: cubit.rooms.length,
              itemBuilder: (context, index) {
                final item = cubit.rooms[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Id: ${item.id}'),
                              const SizedBox(height: 4),
                              Text('Name: ${item.name}'),
                              const SizedBox(height: 4),
                              Text('Floor Id: ${item.floorId}'),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            cubit.getSkywayToken(item);
                          },
                          child: const Text('Join'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> requestPermission() async {
    if ((await Permission.camera.status) != PermissionStatus.granted) {
      await Permission.camera.request();
    }
    if ((await Permission.microphone.status) != PermissionStatus.granted) {
      await Permission.microphone.request();
    }
  }

  Future<void> onConnect(AuthenticationData data) async {
    if (!context.mounted) return;
    await requestPermission();
    try {
      await SkyWay.connect(
        authToken: data.token,
      ).then((value) async {
        context.showToastMessage(
          value ? 'Set up success' : 'Set up fail',
          value ? ToastMessageType.success : ToastMessageType.error,
        );
        if (value) {
          await SkyWay.joinRoom(
            memberName: SessionUtils.getUser()?.onamae.toString() ?? '',
            roomName: 'DEVELOPMENT-${data.room.id}',
          ).then((member) {
            if (member == null) {
              context.showToastMessage(
                'Join room fail. Member with name ${data.memberName} already exists',
                ToastMessageType.error,
              );
            } else {
              injector<SocketService>().joinRoom(
                roomId: data.room.id ?? 0,
                user: SessionUtils.getUser()?.onamae.toString() ?? '',
                floorId: data.room.floorId ?? 0,
                userId: SessionUtils.getUser()?.id ?? 0,
                timeJoinRoom: DateTime.now(),
              );
            }
          });
        } else {
          await Future.delayed(Duration.zero).then(
            (value) {
              context.showToastMessage(
                'Set up fail',
                ToastMessageType.error,
              );
            },
          );
        }
      });
    } on Exception catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text('$error'),
        ),
      );
    }
  }
}
