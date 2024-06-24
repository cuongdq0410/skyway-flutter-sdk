import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_skyway_android/flutter_skyway_android.dart';
import 'package:flutter_skyway_platform_interface/flutter_skyway_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterSkywayAndroid', () {
    const kPlatformName = 'Android';
    late FlutterSkywayAndroid flutterSkyway;
    late List<MethodCall> log;

    setUp(() async {
      flutterSkyway = FlutterSkywayAndroid();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(flutterSkyway.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      FlutterSkywayAndroid.registerWith();
      expect(FlutterSkywayPlatform.instance, isA<FlutterSkywayAndroid>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await flutterSkyway.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
