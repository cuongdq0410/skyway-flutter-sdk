import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skyway_example/ui/widget/app_navigator.dart';

abstract class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});
}

abstract class BaseState<S extends BaseScreen, C extends Cubit>
    extends State<S> {
  late C cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<C>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      afterBuild();
    });
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildContent(context);
  }

  afterBuild();

  Widget buildContent(BuildContext context);

  hideKeyboard() {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  }

  ///***************************************************************************
  /// NAVIGATOR
  ///***************************************************************************

  Future<dynamic> pushScreen(String routeName, {dynamic arguments}) {
    debugPrint("pushScreen ===> $routeName");
    return AppNavigator.navigateTo(context, routeName, arguments: arguments);
  }

  Future<dynamic> push(Widget screen) {
    return Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) {
          return screen;
        },
      ),
    );
  }

  void pushDialog(StatefulWidget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        pageBuilder: (_, __, ___) => screen,
      ),
    );
  }

  void replaceScreen(String routeName, {dynamic arguments}) {
    Navigator.popUntil(context, (route) => route.isFirst);
    debugPrint("replaceScreen ===> $routeName");
    AppNavigator.navigateTo(
      context,
      routeName,
      arguments: arguments,
      stackAction: NavigatorStackAction.replace,
    );
  }

  void popScreen() {
    debugPrint("popScreen <=== ");
    Navigator.of(context).pop();
  }

  void popMultiScreen(int pop) {
    for (int i = 0; i < pop; i++) {
      Navigator.of(context).pop();
    }
  }

  void popUntilScreen(Type screen) {
    debugPrint("${screen.toString()} <=== popUntilScreen");
    Navigator.popUntil(
      context,
      (route) => route.isFirst || route.settings.name == screen.toString(),
    );
  }
}
