import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_skyway_platform_interface/flutter_skyway_platform_interface.dart';

/// The Android implementation of [FlutterSkywayPlatform].
class FlutterSkywayAndroid extends FlutterSkywayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_skyway_android');

  /// Event channel used to receive join room event
  final joinCallEventChannel =
      const EventChannel('flutter_skyway_android/join_call_channel');

  ///  Event channel used to receive list member in room
  final memberListChangeEventChannel =
      const EventChannel('flutter_skyway_android/member_list_change_channel');

  ///  Event channel used to receive a member join room
  final memberJoinedEventChannel =
      const EventChannel('flutter_skyway_android/member_joined_channel');

  ///  Event channel used to receive a member left room
  final memberLeftEventChannel =
      const EventChannel('flutter_skyway_android/member_left_channel');

  /// Registers this class as the default instance of [FlutterSkywayPlatform]
  static void registerWith() {
    FlutterSkywayPlatform.instance = FlutterSkywayAndroid();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<bool> connect({
    required String authToken,
  }) async {
    final result = await methodChannel.invokeMethod<String>('connect', {
      'authToken': authToken,
    });
    return result == 'success';
  }

  @override
  Future<bool> leaveRoom() async {
    return (await methodChannel.invokeMethod<String>('leaveRoom') ?? '') ==
        'success';
  }

  @override
  Stream<JoinCallEvent> onJoinCallStream() {
    return joinCallEventChannel.receiveBroadcastStream().map((event) {
      if (event == JoinCallEvent.joining.name) return JoinCallEvent.joining;
      if (event == JoinCallEvent.joinSuccess.name) {
        return JoinCallEvent.joinSuccess;
      }
      if (event == JoinCallEvent.joinFail.name) return JoinCallEvent.joinFail;
      return JoinCallEvent.none;
    });
  }

  @override
  Future<bool> subscribePublications() async {
    return (await methodChannel.invokeMethod<String>('subscribePublications') ??
            '') ==
        'success';
  }

  @override
  RoomController roomController() {
    return RoomController(
      onMemberListChangedHandler:
          memberListChangeEventChannel.receiveBroadcastStream().map((data) {
        return ((json.decode(data as String) as List?) ?? []).map((e) {
          return RoomMember.fromMap(e as Map<String, dynamic>);
        }).toList();
      }),
      onMemberJoinedHandler:
          memberJoinedEventChannel.receiveBroadcastStream().map(
        (data) {
          return RoomMember.fromMap(
            json.decode(data as String) as Map<String, dynamic>,
          );
        },
      ),
      onMemberLeftHandler: memberLeftEventChannel.receiveBroadcastStream().map(
        (data) {
          return RoomMember.fromMap(
            json.decode(data as String) as Map<String, dynamic>,
          );
        },
      ),
    );
  }

  @override
  Future<List<RoomMember>> getRemoteMemberList() async {
    final data =
        await methodChannel.invokeMethod<String>('getRemoteMemberList');
    if (data == null) return [];
    return ((json.decode(data) as List?) ?? []).map((e) {
      return RoomMember.fromMap(e as Map<String, dynamic>);
    }).toList();
  }

  @override
  Future<RoomMember?> joinRoom({
    required String memberName,
    required String roomName,
    bool isVideo = false,
  }) async {
    final data = await methodChannel.invokeMethod<String>(
      'joinRoom',
      {
        'memberName': memberName,
        'roomName': roomName,
        'isVideo': isVideo,
      },
    );
    return data == null
        ? null
        : RoomMember.fromMap(
            json.decode(data) as Map<String, dynamic>,
          );
  }

  @override
  Future<RoomMember?> getLocalMember() async {
    final data = await methodChannel.invokeMethod<String>('getLocalMember');
    return data == null
        ? null
        : RoomMember.fromMap(
            json.decode(data) as Map<String, dynamic>,
          );
  }

  @override
  Future<void> mute() async {
    await methodChannel.invokeMethod<String>(
      'toggleMic',
      {
        'isMute': true,
      },
    );
  }

  @override
  Future<void> unMute() async {
    await methodChannel.invokeMethod<String>(
      'toggleMic',
      {
        'isMute': false,
      },
    );
  }
}
