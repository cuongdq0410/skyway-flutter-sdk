import 'package:flutter_skyway_platform_interface/flutter_skyway_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class FlutterSkywayMock extends FlutterSkywayPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;

  @override
  Future<bool> connect({
    required String authToken,
  }) {
    throw UnimplementedError();
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('FlutterSkywayPlatformInterface', () {
    late FlutterSkywayPlatform flutterSkywayPlatform;

    setUp(() {
      flutterSkywayPlatform = FlutterSkywayMock();
      FlutterSkywayPlatform.instance = flutterSkywayPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await FlutterSkywayPlatform.instance.getPlatformName(),
          equals(FlutterSkywayMock.mockPlatformName),
        );
      });
    });
  });
}
