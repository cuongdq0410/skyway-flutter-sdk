import 'package:flutter/material.dart';
import 'package:flutter_skyway/flutter_skyway.dart';
import 'package:flutter_skyway_platform_interface/flutter_skyway_platform_interface.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  List<RoomMember> remoteListMember = [];
  RoomMember? localMember;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    await SkyWay.getRemoteMemberList().then((members) {
      setState(() {
        remoteListMember = List.from(members);
      });
    });
    await SkyWay.getLocalMember().then((value) {
      setState(() {
        localMember = value;
      });
    });
    SkyWay.roomController()
      ..onMemberJoinedHandler.listen((member) {
        if (mounted) {
          setState(() {
            final index = remoteListMember
                .indexWhere((element) => element.memberId == member.memberId);
            if (index == -1) {
              remoteListMember.add(member);
            }
          });
        }
      })
      ..onMemberLeftHandler.listen((member) {
        if (mounted) {
          setState(() {
            remoteListMember
                .removeWhere((element) => element.memberId == member.memberId);
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20, right: 50),
                    width: 200,
                    height: 200,
                    child: const SkywayVideoLocal(),
                  ),
                  Row(
                    children: [
                      Text('Name: ${localMember?.memberName}'),
                      IconButton(
                        onPressed: () {
                          if (localMember?.isMute ?? true) {
                            SkyWay.unMute().then((value) {
                              setState(() {
                                localMember?.isMute = false;
                              });
                            });
                          } else {
                            SkyWay.mute().then((value) {
                              setState(() {
                                localMember?.isMute = true;
                              });
                            });
                          }
                        },
                        icon: Icon(
                          (localMember?.isMute ?? true)
                              ? Icons.volume_mute_rounded
                              : Icons.volume_up_rounded,
                          size: 36,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  SkyWay.leaveRoom().then((value) {
                    if (value == true && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  });
                },
                child: const Text('Leave room'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Visibility(
            visible: remoteListMember.isNotEmpty,
            child: const Text('Remote View'),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                children: List.generate(
                  remoteListMember.length,
                  (index) => Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: 20, right: 20, top: 20),
                        width: 200,
                        height: 200,
                        child: SkywayVideoRemote(
                          memberId: remoteListMember[index].memberId,
                        ),
                      ),
                      Text('Name: ${remoteListMember[index].memberName}'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SkyWay.leaveRoom();
    super.dispose();
  }
}
