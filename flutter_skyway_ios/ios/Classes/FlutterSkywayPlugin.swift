import Flutter
import UIKit
import SkyWayRoom

enum ChannelName {
    static let skywayMethodChannel = "flutter_skyway_ios"
    static let joinCallEventChannel = "flutter_skyway_ios/join_call_channel"
    static let memberListChangeEventChannel = "flutter_skyway_ios/member_list_change_channel"
    static let memberJoinedEventChannel = "flutter_skyway_ios/member_joined_channel"
    static let memberLeftEventChannel = "flutter_skyway_ios/member_left_channel"
    static let localRendererPlatformView = "flutter_skyway_ios/local_renderer"
    static let remoteRendererPlatformView = "flutter_skyway_ios/remote_renderer"
}

public class FlutterSkywayPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, RoomDelegate, RemoteDataStreamDelegate  {
    
    private var room: SFURoom?
    private var localRoomMember: LocalRoomMember?
    private var localVideoStream: LocalVideoStream?
    private var localAudioStream: LocalAudioStream?
    private var flutterPluginRegistrar: FlutterPluginRegistrar?
    
    private var  joinCallEventSink: FlutterEventSink?
    private var memberListChangeEventSink: FlutterEventSink?
    private var memberJoinedEventSink: FlutterEventSink?
    private var memberLeftEventSink: FlutterEventSink?
    
    private var localView: UIView?
    
    private var remoteRoomMemberList:[RemoteUIView] = []
    
    private var audioPublication: RoomPublication?
    private var videoPublication: RoomPublication?
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: ChannelName.skywayMethodChannel, binaryMessenger: registrar.messenger())
        let instance = FlutterSkywayPlugin()
        instance.flutterPluginRegistrar = registrar
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.registerEventChannel(registrar)
        instance.registerViewFactory(registrar)
    }
    
    public func registerEventChannel(_ registrar: FlutterPluginRegistrar) {
        // Join call event channel
        let joinCallEventChannel = FlutterEventChannel(name: ChannelName.joinCallEventChannel, binaryMessenger: registrar.messenger())
        joinCallEventChannel.setStreamHandler(self)
        
        let memberListChangeEventChannel = FlutterEventChannel(name: ChannelName.memberListChangeEventChannel, binaryMessenger: registrar.messenger())
        memberListChangeEventChannel.setStreamHandler(self)
        
        let memberJoinedEventChannel = FlutterEventChannel(name: ChannelName.memberJoinedEventChannel, binaryMessenger: registrar.messenger())
        memberJoinedEventChannel.setStreamHandler(self)
        
        let memberLeftEventChannel = FlutterEventChannel(name: ChannelName.memberLeftEventChannel, binaryMessenger: registrar.messenger())
        memberLeftEventChannel.setStreamHandler(self)
    }
    
    public func registerViewFactory(_ registrar: FlutterPluginRegistrar) {
        localView = UIView()
        registrar.register(
            FlutterSkywayPlatformViewFactory(messenger: registrar.messenger(), view: localView!), withId: ChannelName.localRendererPlatformView
        )
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch(call.method) {
        case "connect":
            onConnect(call: call, result: result)
            break
        case "joinRoom":
            joinRoom(call: call, result: result)
            break
        case "leaveRoom":
            leaveRoom(call: call, result: result)
            break
        case "getRemoteMemberList":
            getRemoteMemberList(call: call, result: result)
            break
        case  "getLocalMember" :
            getLocalMember(call: call, result: result)
            break
        case  "toggleMic" :
            toggleMic(call: call, result: result)
            break
        default:
            break
        }
    }
    
    public func onConnect(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String:Any]
        if let args = arguments {
            let authToken = args["authToken"] as? String ?? ""
            Task {
                do {
                    let opt: ContextOptions = .init()
                        opt.logLevel = .trace
                    try await Context.setup(withToken: authToken, options: opt)
                    result("success")
                }
                catch {
                    result("fail")
                }
            }
            
        } else {
            result("fail")
        }
    }
    
    public func joinRoom(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String:Any]
        if let args = arguments {
            let memberName = args["memberName"] as? String ?? ""
            let roomName = args["roomName"] as? String ?? ""
            let isVideo = args["isVideo"] as? Bool ?? false
            Task {
                DispatchQueue.main.sync {
                    self.joinCallEventSink?("joining")
                }
                // Create room
                let roomInit: Room.InitOptions = .init()
                roomInit.name = roomName
                room = try? await SFURoom.findOrCreate(with: roomInit)
                if(room == nil){
                    result(nil)
                    return
                }
                room?.delegate = self
                // Join room
                let memberInit: Room.MemberInitOptions = .init()
                memberInit.name = memberName
                localRoomMember = try? await room?.join(with: memberInit)
                if(localRoomMember == nil){
                    result(nil)
                    DispatchQueue.main.sync {
                        self.joinCallEventSink?("joinFail")
                    }
                    return
                }
                fetchRemoteMemberList()
                
                // AudioStreamの作成
                let audioSource: MicrophoneAudioSource = .init()
                localAudioStream = audioSource.createStream()

                // Publish local audio, video
                let pubAudio = try? await localRoomMember?.publish(localAudioStream!, options: nil)
                audioPublication = pubAudio
                if( pubAudio == nil){
                    print("Publishing audio failed.")
                }

                if(isVideo){
                // Cameraの設定
                    let camera = CameraVideoSource.supportedCameras().first(where: { $0.position == .front })

                    if(camera != nil) {
                        try! await CameraVideoSource.shared().startCapturing(with: camera!, options: nil)
                    }else{
                        print("Supported cameras is not found.");
                    }

                    // VideoStreamの作成
                    localVideoStream = CameraVideoSource.shared().createStream()
                    let cameraView = await CameraPreviewView()
                    // Previewの描画
                    DispatchQueue.main.sync {
                        cameraView.translatesAutoresizingMaskIntoConstraints = false
                        cameraView.frame =
                        CGRect(
                            x: 0, y: 0,
                            width: 200,
                            height: 200
                        )
                        cameraView.contentMode = .scaleAspectFit
                        CameraVideoSource.shared().attach(cameraView)
                        localView?.addSubview(cameraView)

                        NSLayoutConstraint.activate([
                            cameraView.leadingAnchor.constraint(equalTo: localView!.leadingAnchor),
                            cameraView.trailingAnchor.constraint(equalTo: localView!.trailingAnchor),
                            cameraView.topAnchor.constraint(equalTo: localView!.topAnchor),
                            cameraView.bottomAnchor.constraint(equalTo: localView!.bottomAnchor)
                        ])
                    }

                    let pubVideo = try? await localRoomMember?.publish(localVideoStream!, options: nil)
                    videoPublication = pubVideo
                    if(pubVideo == nil){
                        print(" Publishing video failed.")
                    }
                }

                // Subscribe remote publication
                await subscribePublications()


                // Join room success
                result(roomMemberString(member: localRoomMember!))
                DispatchQueue.main.sync {
                    self.joinCallEventSink?("joinSuccess")
                }
            }
            
        } else {
            result(nil)
            DispatchQueue.main.sync {
                self.joinCallEventSink?("joinFail")
            }
        }
    }
    
    public func leaveRoom(call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task {
            if (localRoomMember != nil) {
                try? await localRoomMember?.leave()
                try? await room?.leave(localRoomMember!)
                try? await room?.dispose()
                localRoomMember = nil
                room = nil
                audioPublication = nil
                videoPublication = nil
                for subview in await localView!.subviews {
                    await subview.removeFromSuperview()
                }
                CameraVideoSource.shared().stopCapturing()
                try? await Context.dispose()
                result("success")
            }else{
                result(nil)
            }
        }
    }
    
    public func getRemoteMemberList(call: FlutterMethodCall, result: @escaping FlutterResult){
        fetchRemoteMemberList()
        var memberJsonList = [String]()
        for member in remoteRoomMemberList {
            if let data = roomMemberInfoString(member: member.member){
                memberJsonList.append(data)
            }
        }
        result("\(memberJsonList)")
    }
    
    private func getLocalMember(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (localRoomMember != nil) {
            result(roomMemberString(member: localRoomMember!))
        } else {
            result(nil)
        }
    }
    
    public func fetchRemoteMemberList() {
        let members:[RoomMember] = room?.members ?? []
        for (remoteIndex, remoteMem) in remoteRoomMemberList.enumerated() {
            let isInRoom = members.firstIndex(where: { $0.id == remoteMem.member.id }) != -1
            if (!isInRoom) {
                remoteRoomMemberList.remove(at: remoteIndex)
            }
        }
        for member in members {
            addRemoteMemberAndRegisterView(member: member)
        }
    }
    
    private func addRemoteMemberAndRegisterView(
        member: RoomMember,
        completion: (() -> Void)? = nil
    ) {
        let isRemoteMemberInList = remoteRoomMemberList.contains { $0.member.id == member.id }
        if(isRemoteMemberInList){
            return
        }
        if(member.id == localRoomMember?.id || localRoomMember == nil){
            return
        }
        DispatchQueue.main.async {
            let remoteView = UIView()
            self.flutterPluginRegistrar!.register(
                FlutterSkywayPlatformViewFactory(messenger: self.flutterPluginRegistrar!.messenger(), view: remoteView), withId:  "\(ChannelName.remoteRendererPlatformView)/\(member.id)"
            )
            self.remoteRoomMemberList.append(
                RemoteUIView(
                    member: RemoteRoomMemberInfo(id: member.id, name: member.name),
                    uiView:  remoteView
                )
            )
        }
        if(completion != nil){
            completion!()
        }
    }
    
    public func subscribePublications() async {
        for pub in room?.publications ?? [] {
            if(pub.publisher?.id != localRoomMember?.id){
                subscribe(publication: pub)
            }
        }
    }
    
    private func toggleMic(call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task {
            let arguments = call.arguments as? [String:Any]
            if let args = arguments {
                let isMute = args["isMute"] as? Bool ?? false
                if (isMute) {
                    try? await audioPublication?.disable()
                } else {
                    try? await audioPublication?.enable()
                }
                result("success")
            }
        }
    }
    
    private func unPublish(roomPublication: RoomPublication) {
        Task{
            try? await localRoomMember?.unpublish(publicationId: roomPublication.id)
        }
    }
    
    // MARK: - RoomDelegate
    public func room(_ room: Room, didPublishStreamOf publication: RoomPublication) {
        if publication.publisher?.id != localRoomMember?.id {
            subscribe(publication: publication)
        }
    }
    
    public func roomMemberListDidChange(_ room: Room) {
        var memberJsonList = [String]()
        for member in self.room?.members ?? [] {
            if let data = roomMemberString(member: member){
                memberJsonList.append(data)
            }
        }
        print("roomMemberListDidChange: \(memberJsonList)")
        DispatchQueue.main.sync {
            self.memberListChangeEventSink?("\(memberJsonList)")
        }
    }
    
    public func room(_ room: Room, memberDidJoin member: RoomMember) {
        DispatchQueue.main.sync {
            addRemoteMemberAndRegisterView(member: member) { [self] in
                self.memberJoinedEventSink?(self.roomMemberString(member: member))
            }
        }
    }
    
    public func room(_ room: Room, memberDidLeave member: RoomMember) {
        DispatchQueue.main.sync {
            let index = remoteRoomMemberList.firstIndex(where: { $0.member.id == member.id })
            if(index == -1 || index == nil){
                return
            }
            self.memberLeftEventSink?(roomMemberString(member: member))
            remoteRoomMemberList[index!].uiView = UIView()
            remoteRoomMemberList.remove(at: index!)
        }
    }
    
    public func subscribe(publication: RoomPublication) {
        Task {
            let opt: SubscriptionOptions = .init()
            let sub = try? await localRoomMember?.subscribe(publicationId: publication.id, options: opt)
            if(sub == nil){
                return
            }
            DispatchQueue.main.sync {
                if(sub?.stream is RemoteVideoStream){
                    let index =
                    remoteRoomMemberList.firstIndex(where: { $0.member.id == publication.publisher?.id })
                    if (index == -1 || index == nil){
                        return
                    }
                    let videoView = VideoView()
                    videoView.frame =
                    CGRect(
                        x: 0, y: 0,
                        width: 200,
                        height: 200
                    )
                    videoView.videoContentMode = .scaleAspectFit
                    let remoteVideoStream = sub!.stream as! RemoteVideoStream
                    remoteVideoStream.attach(videoView)
                    remoteRoomMemberList[index!].uiView.addSubview(videoView)
                }
            }
        }
    }
    
    public func roomMemberString(member: RoomMember)-> String?{
        let data: [String: Any] = [
            "memberId": member.id,
            "memberName": member.name ?? "",
            "isRemoteMember": member.id != localRoomMember?.id,
            "isMute" : member.id == localRoomMember?.id ? audioPublication == nil : false,
            "isVideo": member.id == localRoomMember?.id ? videoPublication != nil : false
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error: \(error)")
        }
        return nil
    }
    
    func roomMemberInfoString(member: RemoteRoomMemberInfo)-> String?{
        let data: [String: Any] = [
            "memberId": member.id,
            "memberName": member.name ?? "",
            "isRemoteMember": member.id != localRoomMember?.id,
            "isMute" : member.id == localRoomMember?.id ? audioPublication == nil : false,
            "isVideo": member.id == localRoomMember?.id ? videoPublication != nil : false
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error: \(error)")
        }
        return nil
    }
    
    // Assign event channel sink
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        if arguments as? String == ChannelName.joinCallEventChannel {
            joinCallEventSink = events
        }
        
        if arguments as? String == ChannelName.memberListChangeEventChannel {
            memberListChangeEventSink = events
        }
        if arguments as? String == ChannelName.memberJoinedEventChannel {
            memberJoinedEventSink = events
        }
        
        if arguments as? String == ChannelName.memberLeftEventChannel {
            memberLeftEventSink = events
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        joinCallEventSink = nil
        return nil
    }
    
}

class RemoteUIView {
    var member: RemoteRoomMemberInfo
    var uiView: UIView
    
    init(member: RemoteRoomMemberInfo, uiView: UIView) {
        self.member = member
        self.uiView = uiView
    }
}

class RemoteRoomMemberInfo {
    var id: String
    var name: String?
    
    init(id: String, name: String?) {
        self.id = id
        self.name = name
    }
}
