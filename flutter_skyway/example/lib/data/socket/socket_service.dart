import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_skyway_example/data/storage/session_utils.dart';

class SocketService {
  SocketService() {
    socket = io(
      'wss://socket-dev.voichat.com',
      OptionBuilder() //
          .setTransports(['websocket', 'polling'])
          .disableForceNew()
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(500)
          .setReconnectionDelayMax(3000)
          .build(),
    )
      ..onConnect(_onConnect)
      ..onReconnect(_onReconnect)
      ..onDisconnect(_onDisconnect)
      ..onConnectError((_) => print('Socket Error: $_'))
      ..on('join-room', onJoinRoom);
  }

  late Socket socket;

  final connectCtrl = StreamController<bool>.broadcast();
  final reconnectCtrl = StreamController<bool>.broadcast();

  Future<void> connect() async {
    final user = SessionUtils.getUser();
    if (user == null) return;
    socket
      ..auth = {
        'uid': user.uid,
        'userId': user.id,
        'floorId': user.floorId,
      }
      ..disconnect()
      ..connect();
  }

  Stream<bool> get onConnect => connectCtrl.stream;

  Stream<bool> get onReconnect => reconnectCtrl.stream;

  Future<void> disconnect() async => socket.disconnect();

  Future<void> _onConnect(dynamic data) async {
    print('Socket connected!');
    print('Socket pingInterval: ${socket.io.engine?.pingInterval}');
    print('Socket pingTimeout: ${socket.io.engine?.pingTimeout}');
    print('Socket options: ${socket.io.options}');
    connectCtrl.add(socket.connected);
  }

  Future<void> _onDisconnect(dynamic data) async {
    print('Socket disconnect!');
    connectCtrl.add(socket.connected);
  }

  Future<void> _onReconnect(dynamic data) async {
    print('Socket onReconnect...');
    reconnectCtrl.add(true);
  }

  Future<void> onJoinRoom(dynamic data) async {
    print('Socket event: onJoinRoom!');
    print('$data');
  }

  void joinRoom({
    required int roomId,
    required String user,
    required int floorId,
    required int userId,
    required DateTime timeJoinRoom,
    int? oldFloorId,
    int? oldRoom,
    bool statusMic = false,
    bool statusSpeaker = true,
  }) {
    final params = {
      'user': user,
      'userId': userId,
      'room_id': roomId,
      'floor_id': floorId,
      'old_room': oldRoom,
      'old_floor_id': oldFloorId,
      'time_join_room': timeJoinRoom.millisecondsSinceEpoch,
      'status_mic': statusMic,
      'status_speaker': statusSpeaker,
    };
    print(params);
    socket.emit('join-room', params);
  }
}
