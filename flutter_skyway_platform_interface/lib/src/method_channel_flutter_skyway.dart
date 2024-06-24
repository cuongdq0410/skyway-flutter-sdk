import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:flutter_skyway_platform_interface/flutter_skyway_platform_interface.dart';

/// An implementation of [FlutterSkywayPlatform] that uses method channels.
class MethodChannelFlutterSkyway extends FlutterSkywayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_skyway');

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<bool> connect({
    required String authToken,
  }) async {
    throw UnimplementedError('methodChannel connect');
  }

  @override
  Future<bool> leaveRoom() {
    throw UnimplementedError();
  }

  @override
  Stream<JoinCallEvent> onJoinCallStream() {
    throw UnimplementedError();
  }

  @override
  Future<bool> subscribePublications() {
    throw UnimplementedError();
  }

  @override
  RoomController roomController() {
    throw UnimplementedError();
  }

  @override
  Future<List<RoomMember>> getRemoteMemberList() {
    throw UnimplementedError();
  }

  @override
  Future<RoomMember?> joinRoom({
    required String memberName,
    required String roomName,
    bool isVideo = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RoomMember?> getLocalMember() {
    throw UnimplementedError();
  }

  @override
  Future<void> mute() {
    throw UnimplementedError();
  }

  @override
  Future<void> unMute() {
    throw UnimplementedError();
  }
}
