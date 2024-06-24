import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_skyway/flutter_skyway.dart';
import 'package:flutter_skyway_example/data/responses/room_list_response.dart';
import 'package:flutter_skyway_example/injection/dependency_manager.dart';
import 'package:flutter_skyway_example/ui/call_room/ui/call_page.dart';
import 'package:flutter_skyway_platform_interface/flutter_skyway_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';

import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyManager.inject();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _platformName;
  bool isLoading = false;
  final TextEditingController roomNameTC = TextEditingController();
  final TextEditingController memberNameTC = TextEditingController();

  @override
  void initState() {
    super.initState();
    SkyWay.onJoinCallStream().listen((event) {
      if (event == JoinCallEvent.joining) {
        setState(() {
          isLoading = true;
        });
      }
      if (event == JoinCallEvent.joinSuccess) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CallPage()),
        );

        setState(() {
          isLoading = false;
        });
      }
      if (event == JoinCallEvent.joinFail) {
        setState(() {
          isLoading = false;
        });
      }
    });
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
      final result = await SkyWay.connect(
        authToken: data.token,
      );
      setState(() => _platformName = result ? 'Set up success' : 'Set up fail');
      if (result) {
        await SkyWay.joinRoom(
          memberName: data.memberName,
          roomName: data.room.id.toString(),
        ).then((member) {
          if (member == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).primaryColor,
                content: Text(
                    'Join room fail. Member with name ${data.memberName} already exists'),
              ),
            );
          }
        });
      } else {
        await Future.delayed(Duration.zero).then(
          (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).primaryColor,
                content: const Text('Set up Skyway fail'),
              ),
            );
          },
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlutterSkyway Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator()
            else
              const SizedBox(),
            const SizedBox(height: 16),
            if (_platformName == null)
              const SizedBox.shrink()
            else
              Text(
                '$_platformName',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextField(
                    controller: roomNameTC,
                    decoration: const InputDecoration(labelText: 'Room name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: memberNameTC,
                    decoration: const InputDecoration(labelText: 'Member name'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                final dio = Dio();
                await dio.post(
                  'http://voichat-api.thekyros.net/authenticate',
                  data: {
                    'channelName': roomNameTC.text,
                    'memberName': memberNameTC.text,
                    'sessionToken': '4CXS0f19nvMJBYK05o3toTWtZF5Lfd2t6Ikr2lID'
                  },
                ).then((response) async {
                  if (response.statusCode == 200) {
                    // await onConnect(
                    //   AuthenticationData(
                    //     response.data['authToken'] as String? ?? '',
                    //     memberNameTC.text,
                    //     'roomNameTC.text',
                    //   ),
                    // );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).primaryColor,
                        content: const Text('Get token fail'),
                      ),
                    );
                  }
                });
              },
              child: const Text('Join room'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthenticationData {
  AuthenticationData(this.token, this.memberName, this.room);

  final String token;
  final String memberName;
  final RoomItemResponse room;
}
