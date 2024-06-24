import 'package:flutter_skyway_platform_interface/flutter_skyway_platform_interface.dart';

FlutterSkywayPlatform get _platform => FlutterSkywayPlatform.instance;

/// Returns the name of the current platform.
class SkyWay {
  /// Returns the name of the current platform.
  static Future<String> getPlatformName() async {
    final platformName = await _platform.getPlatformName();
    if (platformName == null) throw Exception('Unable to get platform name.');
    return platformName;
  }

  ///
  static Future<bool> connect({
    required String authToken,
  }) async {
    final connected = await _platform.connect(
      authToken: authToken,
    );
    return connected;
  }

  ///
  static Future<bool> leaveRoom() async {
    final result = await _platform.leaveRoom();
    return result;
  }

  ///
  static Stream<JoinCallEvent> onJoinCallStream() {
    return _platform.onJoinCallStream();
  }

  ///
  static Future<bool> subscribePublications() {
    return _platform.subscribePublications();
  }

  ///
  static RoomController roomController() {
    return _platform.roomController();
  }

  ///
  static Future<List<RoomMember>> getRemoteMemberList() {
    return _platform.getRemoteMemberList();
  }

  ///
  static Future<RoomMember?> joinRoom({
    required String memberName,
    required String roomName,
    bool isVideo = false,
  }) async {
    return _platform.joinRoom(
      memberName: memberName,
      roomName: roomName,
      isVideo: isVideo,
    );
  }

  ///
  static Future<RoomMember?> getLocalMember() async {
    return _platform.getLocalMember();
  }

  ///
  static Future<void> mute() async {
    return _platform.mute();
  }

  ///
  static Future<void> unMute() async {
    return _platform.unMute();
  }
}
