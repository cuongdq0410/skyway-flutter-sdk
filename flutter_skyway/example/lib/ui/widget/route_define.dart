import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skyway_example/ui/home/cubit/home_cubit.dart';
import 'package:flutter_skyway_example/ui/home/ui/home_screen.dart';
import 'package:flutter_skyway_example/ui/login/cubit/login_cubit.dart';
import 'package:flutter_skyway_example/ui/login/ui/login_screen.dart';
import 'package:flutter_skyway_example/ui/splash/splash_screen.dart';

enum RouteDefine {
  splashScreen,
  loginScreen,
  homeScreen,
}

class GenerateRoute {
  static PageRoute generateRoute(RouteSettings settings) {
    final routes = <String, WidgetBuilder>{
      RouteDefine.loginScreen.name: (_) => widgetBuilder(
            const LoginScreen(),
            cubit: LoginCubit(),
          ),
      RouteDefine.homeScreen.name: (_) => widgetBuilder(
            const HomeScreen(),
            cubit: HomeCubit(),
          ),
      RouteDefine.splashScreen.name: (_) => widgetBuilder(
            const SplashScreen(),
          ),
    };

    final routeBuilder = routes[settings.name];
    return CupertinoPageRoute(
      settings: RouteSettings(name: settings.name),
      builder: (context) => routeBuilder!(context),
    );
  }

  static Widget widgetBuilder<T extends Cubit, S extends Widget>(
    S screen, {
    T? cubit,
  }) {
    return cubit == null
        ? screen
        : BlocProvider<T>(
            create: (context) => cubit,
            child: screen,
          );
  }

  static Widget widgetBuilderBlocValue<T extends Cubit, S extends Widget>(
    S screen, {
    T? cubit,
  }) {
    return cubit == null
        ? screen
        : BlocProvider<T>.value(
            value: cubit,
            child: screen,
          );
  }
}
