import 'package:flutter/material.dart';
import 'package:flutter_skyway_example/data/storage/session_utils.dart';
import 'package:flutter_skyway_example/ui/widget/app_navigator.dart';
import 'package:flutter_skyway_example/ui/widget/route_define.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      if (SessionUtils.getAccessToken() != null) {
        AppNavigator.navigateTo(context, RouteDefine.homeScreen.name);
      } else {
        AppNavigator.navigateTo(context, RouteDefine.loginScreen.name);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
