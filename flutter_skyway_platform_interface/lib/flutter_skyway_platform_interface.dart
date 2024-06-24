import 'package:flutter_skyway_platform_interface/src/method_channel_flutter_skyway.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of flutter_skyway must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `FlutterSkyway`.
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
///  this interface will be broken by newly added [FlutterSkywayPlatform] methods.
abstract class FlutterSkywayPlatform extends PlatformInterface {
  /// Constructs a FlutterSkywayPlatform.
  FlutterSkywayPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSkywayPlatform _instance = MethodChannelFlutterSkyway();

  /// The default instance of [FlutterSkywayPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSkyway].
  static FlutterSkywayPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterSkywayPlatform] when they register themselves.
  static set instance(FlutterSkywayPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Return the current platform name.
  Future<String?> getPlatformName();

  /// connect to skyway
  Future<bool> connect({
    required String authToken,
  });

  /// join room
  Future<RoomMember?> joinRoom({
    required String memberName,
    required String roomName,
    bool isVideo = false,
  });

  /// Left Room
  Future<bool> leaveRoom();

  /// Join call stream event
  Stream<JoinCallEvent> onJoinCallStream();

  /// Subscribe Publications
  Future<bool> subscribePublications();

  ///
  RoomController roomController();

  /// Get member in room
  Future<List<RoomMember>> getRemoteMemberList();

  /// Get local member in room
  Future<RoomMember?> getLocalMember();

  /// Mute mic
  Future<void> mute();

  /// UnMute mic
  Future<void> unMute();
}

/// Event join call
enum JoinCallEvent {
  /// none
  none,

  /// user is joining room
  joining,

  /// user joined room successfully
  joinSuccess,

  /// user joined room fail
  joinFail,
}

/// Use to handle event in room
class RoomController {
  /// Constructor
  RoomController({
    required this.onMemberListChangedHandler,
    required this.onMemberJoinedHandler,
    required this.onMemberLeftHandler,
  });

  /// List member change on room
  final Stream<List<RoomMember>> onMemberListChangedHandler;

  /// Member joined room
  final Stream<RoomMember> onMemberJoinedHandler;

  /// Member left room
  final Stream<RoomMember> onMemberLeftHandler;
}

/// Room member
class RoomMember {
  /// Constructor
  RoomMember({
    required this.memberId,
    required this.memberName,
    required this.isRemoteMember,
    required this.isMute,
    required this.isVideo,
  });

  ///
  factory RoomMember.fromMap(Map<String, dynamic> map) {
    return RoomMember(
      memberId: map['memberId'] as String? ?? '',
      memberName: map['memberName'] as String? ?? '',
      isRemoteMember: map['isRemoteMember'] as bool? ?? false,
      isMute: map['isMute'] as bool? ?? true,
      isVideo: map['isVideo'] as bool? ?? false,
    );
  }

  /// Room member id
  final String memberId;

  /// Room member name
  final String memberName;

  /// Check remote member or not
  final bool isRemoteMember;

  /// Check mic on/off
  bool isMute;

  /// Check video on/off
  bool isVideo;
}
