import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_skyway_example/ui/widget/app_navigator.dart';
import 'package:flutter_skyway_example/ui/widget/keyboard_utils.dart';
import 'package:flutter_skyway_example/ui/widget/route_define.dart';
import 'package:flutter_skyway_example/ui/widget/toast_message/toast_message.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          navigatorKey: AppNavigator.navigatorKey,
          title: "Voice Chat",
          debugShowCheckedModeBanner: false,
          initialRoute: RouteDefine.splashScreen.name,
          onGenerateRoute: GenerateRoute.generateRoute,
          builder: _materialBuilder,
        );
      },
    );
  }

  Overlay _materialBuilder(BuildContext context, Widget? child) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
            return Material(
              child: GestureDetector(
                onTap: () {
                  KeyboardUtils.hideKeyboard(context);
                },
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: toastBuilder(context, child!),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
