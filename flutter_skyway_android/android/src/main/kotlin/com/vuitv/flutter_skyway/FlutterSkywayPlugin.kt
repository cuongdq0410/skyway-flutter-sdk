package com.vuitv.flutter_skyway

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import androidx.annotation.NonNull
import androidx.constraintlayout.widget.ConstraintLayout
import com.ntt.skyway.core.SkyWayContext
import com.ntt.skyway.core.content.Stream
import com.ntt.skyway.core.content.local.LocalAudioStream
import com.ntt.skyway.core.content.local.LocalVideoStream
import com.ntt.skyway.core.content.local.source.AudioSource
import com.ntt.skyway.core.content.local.source.CameraSource
import com.ntt.skyway.core.content.remote.RemoteAudioStream
import com.ntt.skyway.core.content.remote.RemoteDataStream
import com.ntt.skyway.core.content.remote.RemoteVideoStream
import com.ntt.skyway.core.content.sink.SurfaceViewRenderer
import com.ntt.skyway.core.util.Logger
import com.ntt.skyway.room.RoomPublication
import com.ntt.skyway.room.RoomSubscription
import com.ntt.skyway.room.member.LocalRoomMember
import com.ntt.skyway.room.member.RemoteRoomMember
import com.ntt.skyway.room.member.RoomMember
import com.ntt.skyway.room.sfu.SFURoom

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import org.json.JSONObject

class FlutterSkywayPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null

    //
    private lateinit var option: SkyWayContext.Options

    // メンバの宣言
    private val scope = CoroutineScope(Dispatchers.IO)
    private var localRoomMember: LocalRoomMember? = null
    private var room: SFURoom? = null
    private var localVideoStream: LocalVideoStream? = null
    private var localAudioStream: LocalAudioStream? = null

    private var audioPublication: RoomPublication? = null
    private var videoPublication: RoomPublication? = null

    private lateinit var localConstraintLayout: ConstraintLayout

    private val joinCallEventChannel = "flutter_skyway_android/join_call_channel"
    private var joinCallEventSink: EventChannel.EventSink? = null

    private val memberListChangeEventChannel = "flutter_skyway_android/member_list_change_channel"
    private var memberListChangeEventSink: EventChannel.EventSink? = null

    private var memberJoinedEventSink: EventChannel.EventSink? = null
    private val memberJoinedEventChannel = "flutter_skyway_android/member_joined_channel"

    private var memberLeftEventSink: EventChannel.EventSink? = null
    private val memberLeftEventChannel = "flutter_skyway_android/member_left_channel"

    private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding

    private var remoteRoomMemberList: MutableList<RemoteConstrainView> = mutableListOf()


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_skyway_android")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        this.flutterPluginBinding = flutterPluginBinding;
        localConstraintLayout = LayoutInflater.from(context).inflate(
            R.layout.local_render_layout, null
        ) as ConstraintLayout

        registerEventChannel()
        registerViewFactory()
    }


    private fun registerEventChannel() {
        /// Event channel
        EventChannel(flutterPluginBinding.binaryMessenger, joinCallEventChannel).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(p0: Any?, eventSink: EventChannel.EventSink) {
                    joinCallEventSink = eventSink
                }

                override fun onCancel(p0: Any) {
                    joinCallEventSink = null
                }
            },
        )

        EventChannel(
            flutterPluginBinding.binaryMessenger, memberListChangeEventChannel
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(p0: Any?, eventSink: EventChannel.EventSink) {
                    memberListChangeEventSink = eventSink
                }

                override fun onCancel(p0: Any) {
                    memberListChangeEventSink = null
                }
            },
        )

        EventChannel(
            flutterPluginBinding.binaryMessenger, memberJoinedEventChannel
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(p0: Any?, eventSink: EventChannel.EventSink) {
                    memberJoinedEventSink = eventSink
                }

                override fun onCancel(p0: Any) {
                    memberJoinedEventSink = null
                }
            },
        )

        EventChannel(
            flutterPluginBinding.binaryMessenger, memberLeftEventChannel
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(p0: Any?, eventSink: EventChannel.EventSink) {
                    memberLeftEventSink = eventSink
                }

                override fun onCancel(p0: Any) {
                    memberLeftEventSink = null
                }
            },
        )
    }

    private fun registerViewFactory() {
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "flutter_skyway_android/local_renderer",
            FlutterSkywayPlatformViewFactory(localConstraintLayout),
        )
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformName" -> {
                result.success("Android SkyWay")
            }

            "connect" -> {
                onConnect(call, result)
            }

            "joinRoom" -> {
                onJoinRoom(call, result)
            }

            "leaveRoom" -> {
                leaveRoom(call, result)
            }

            "subscribePublications" -> {
                subscribePublications()
            }

            "getRemoteMemberList" -> {
                getRoomRemoteMemberList(call, result)
            }

            "getLocalMember" -> {
                getLocalMember(call, result)
            }

            "toggleMic" -> {
                toggleMic(call, result)
            }

            else -> result.notImplemented()
        }

    }


    private fun onConnect(@NonNull call: MethodCall, @NonNull result: Result) {
        val authToken = call.arguments<HashMap<String, String>>()?.get("authToken") ?: return
        option = SkyWayContext.Options(
            authToken = authToken, logLevel = Logger.LogLevel.VERBOSE, enableHardwareCodec = false
        )

        scope.launch() {
            val connect = context?.let {
                SkyWayContext.setup(it, option)
            }
            GlobalScope.launch(Dispatchers.Main) {
                if (connect == false) {
                    result.success("fail")
                } else {
                    result.success("success")
                }
            }

        }
    }

    private fun onJoinRoom(@NonNull call: MethodCall, @NonNull result: Result) {
        val memberName = call.arguments<HashMap<String, String>>()?.get("memberName") ?: return
        val roomName = call.arguments<HashMap<String, String>>()?.get("roomName") ?: return
        val isVideo = call.arguments<HashMap<String, Boolean>>()?.get("isVideo") ?: return

        scope.launch() {
            GlobalScope.launch(Dispatchers.Main) {
                joinCallEventSink?.success("joining")
            }
            room = SFURoom.findOrCreate(roomName)

            if (room == null) {
                GlobalScope.launch(Dispatchers.Main) {
                    result.success(null)
                    joinCallEventSink?.success("joinFail");
                }
                return@launch
            }

            val memberInit = RoomMember.Init(name = memberName)
            localRoomMember = room?.join(memberInit)

            val resultMessage = if (localRoomMember == null) "Join failed" else "Joined room"
            Log.d("FlutterSkywayPlugin - resultMessage", resultMessage)
            if (localRoomMember == null) {
                GlobalScope.launch(Dispatchers.Main) {
                    result.success(null)
                    joinCallEventSink?.success("joinFail");
                }
                return@launch
            }
            fetchRemoteMemberList()

            // 音声入力を開始します
            AudioSource.start()
            localAudioStream = AudioSource.createStream()
            audioPublication = localRoomMember?.publish(localAudioStream!!)

            if (isVideo) {
                // cameraリソースの取得
                val device = context?.let { CameraSource.getFrontCameras(it).first() }
                // camera映像のキャプチャを開始します
                val cameraOption = CameraSource.CapturingOptions(800, 800)
                context?.let {
                    if (device != null) {
                        CameraSource.startCapturing(it, device, cameraOption)
                    }
                }
                // 描画やpublishが可能なStreamを作成します
                localVideoStream = CameraSource.createStream()

                GlobalScope.launch(Dispatchers.Main) {
                    val localViewRenderer = context?.let { SurfaceViewRenderer(it) }!!
                    localConstraintLayout.removeAllViews()
                    localConstraintLayout.addView(localViewRenderer)
                    localViewRenderer.setup()
                    localVideoStream?.addRenderer(localViewRenderer)
                }
                // publish local
                videoPublication = localRoomMember?.publish(localVideoStream!!)
            }

            subscribePublications()
            roomHandler()

            GlobalScope.launch(Dispatchers.Main) {
                joinCallEventSink?.success("joinSuccess")
                result.success(roomMemberJson(localRoomMember!!).toString())
            }
        }
    }

    private fun subscribePublications() {
        // 入室時に他のメンバーのStreamを購読する
        room?.publications?.forEach {
            if (it.publisher?.id == localRoomMember?.id) {
                return@forEach
            }
            subscribe(it)
        }
        // 誰かがStreamを公開したときに購読する
        room?.onStreamPublishedHandler = Any@{
            Log.d("room", "onStreamPublished: ${it.id}")
            if (it.publisher?.id == localRoomMember?.id) {
                return@Any
            }
            subscribe(it)
        }
    }

    private fun roomHandler() {
        room?.onMemberListChangedHandler = {
            GlobalScope.launch(Dispatchers.Main) {
                memberListChangeEventSink?.success(
                    "${
                        room?.members?.map { roomMemberJson(it) }?.toMutableList() ?: listOf()
                    }"
                )
            }
        }
        room?.onMemberJoinedHandler = {
            GlobalScope.launch(Dispatchers.Main) {
                addRemoteMemberAndRegisterView(it) {
                    memberJoinedEventSink?.success("${roomMemberJson(it)}")
                }
            }
        }
        room?.onMemberLeftHandler = {
            GlobalScope.launch(Dispatchers.Main) {
                val index = remoteRoomMemberList.indexOfFirst { it1 -> it1.member.id == it.id }
                if (index == -1) return@launch
                memberLeftEventSink?.success("${roomMemberJson(it)}")
                remoteRoomMemberList[index].constraintLayout.removeAllViews()
                remoteRoomMemberList.removeAt(index)
            }
        }
    }

    private fun getRoomRemoteMemberList(@NonNull call: MethodCall, @NonNull result: Result) {
        fetchRemoteMemberList()
        result.success(
            "${
                remoteRoomMemberList.map { roomMemberJson(it.member) }.toMutableList()
            }"
        )
    }

    private fun getLocalMember(@NonNull call: MethodCall, @NonNull result: Result) {
        if (localRoomMember != null) {
            result.success(
                "${
                    roomMemberJson(localRoomMember!!)
                }"
            )
        } else {
            result.success(null)
        }
    }

    private fun toggleMic(@NonNull call: MethodCall, @NonNull result: Result) {
        scope.launch() {
            val isMute = call.arguments<HashMap<String, Boolean>>()?.get("isMute") ?: false
            scope.launch(Dispatchers.Main) {
                if (isMute) {
                    audioPublication?.disable()
//                    localAudioStream?.track?.setEnabled(false)
                } else {
                    audioPublication?.enable()
//                    localAudioStream?.track?.setEnabled(true)
                }
            }
            result.success("success")
        }
    }

    private fun unPublish(roomPublication: RoomPublication) {
        scope.launch(Dispatchers.IO) {
            localRoomMember?.unpublish(roomPublication)
        }
    }

    private fun fetchRemoteMemberList() {
        val members: List<RoomMember> = (room?.members ?: listOf()).toMutableList()
        remoteRoomMemberList.forEach(action = {
            val isInRoom = members.indexOfFirst { it1 -> it1.id == it.member.id } != -1
            if (!isInRoom) {
                remoteRoomMemberList.remove(it)
            }
        })
        members.forEach(
            action = {
                addRemoteMemberAndRegisterView(it)
            },
        )
    }

    private fun addRemoteMemberAndRegisterView(
        member: RoomMember, callback: (() -> Unit)? = null
    ) {
        var isRemoteMemberInList = remoteRoomMemberList.any { it.member.id == member.id }
        if (isRemoteMemberInList) {
            return
        }
        if (member.id == localRoomMember?.id || localRoomMember == null) {
            return
        }
        var remoteConstraintLayout = LayoutInflater.from(context)
            .inflate(R.layout.remote_render_layout, null) as ConstraintLayout
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "flutter_skyway_android/remote_renderer/${member.id}",
            FlutterSkywayPlatformViewFactory(remoteConstraintLayout),
        )
        remoteRoomMemberList.add(
            RemoteConstrainView(
                member as RemoteRoomMember, remoteConstraintLayout
            )
        )
        if (callback == null) return
        callback.invoke()
    }

    private fun roomMemberJson(it: RoomMember): JSONObject {
        val rootObject = JSONObject()
        rootObject.put("memberId", it.id)
        rootObject.put("memberName", it.name)
        rootObject.put("isRemoteMember", it.id != localRoomMember?.id)
        if (it.id == localRoomMember?.id) {
            rootObject.put("isMute", audioPublication == null)
            rootObject.put("isVideo", videoPublication != null)
        }
        rootObject
        return rootObject
    }


    // 購読(subscribe)の実装部分
    private fun subscribe(publication: RoomPublication) {
        scope.launch {
            // Publicationをsubscribeします
            val subscription: RoomSubscription? = localRoomMember?.subscribe(publication.id)

            GlobalScope.launch(Dispatchers.Main) {
                val remoteStream = subscription?.stream ?: return@launch

                when (remoteStream.contentType) {
                    // コンポーネントへの描画
                    Stream.ContentType.VIDEO -> {
                        val index =
                            remoteRoomMemberList.indexOfFirst { it1 -> it1.member.id == publication.publisher?.id }
                        if (index == -1) return@launch
                        remoteRoomMemberList[index].constraintLayout.removeAllViews()
                        val remoteViewRenderer = context?.let { SurfaceViewRenderer(it) }!!
                        remoteRoomMemberList[index].constraintLayout.addView(remoteViewRenderer)
                        remoteViewRenderer.setup()
                        (remoteStream as RemoteVideoStream).addRenderer(
                            remoteViewRenderer
                        )
                    }

                    Stream.ContentType.AUDIO -> {
                        (subscription.stream as RemoteAudioStream)
                    }

                    Stream.ContentType.DATA -> {
                        (subscription.stream as RemoteDataStream).onDataHandler = {}

                        (subscription.stream as RemoteDataStream).onDataBufferHandler = {}
                    }

                    else -> {}
                }
            }
        }
    }

    private fun leaveRoom(@NonNull call: MethodCall, @NonNull result: Result) {
        if (localRoomMember != null && SkyWayContext.isSetup) {
            scope.launch(Dispatchers.Main) {
                room?.leave(localRoomMember!!)
                localRoomMember?.leave()
                room?.dispose()
                room = null
                localRoomMember = null
                localAudioStream = null
                audioPublication = null
                videoPublication = null
                localVideoStream?.removeAllRenderer()
                CameraSource.stopCapturing()
                SkyWayContext.dispose()
                result.success("success")
            }
        } else {
            result.success(null)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        if (localRoomMember != null) {
            scope.launch(Dispatchers.IO) {
                room?.leave(localRoomMember!!)

            }
        }
        scope.launch(Dispatchers.IO) {
            room?.dispose()
            room = null
            channel.setMethodCallHandler(null)
            context = null
            CameraSource.stopCapturing()
            audioPublication = null
            videoPublication = null
            localRoomMember = null
            localAudioStream = null
            remoteRoomMemberList.clear()
            SkyWayContext.dispose()
        }
        GlobalScope.launch(Dispatchers.Main) {
            joinCallEventSink?.success("leftRoom")
        }

    }
}

class RemoteConstrainView(member: RemoteRoomMember, constraintLayout: ConstraintLayout) {
    var member: RemoteRoomMember = member
    var constraintLayout: ConstraintLayout = constraintLayout
}