import 'package:flutter_skyway/flutter_skyway.dart';
import 'package:flutter_skyway_platform_interface/flutter_skyway_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSkywayPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FlutterSkywayPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterSkyway', () {
    late FlutterSkywayPlatform flutterSkywayPlatform;

    setUp(() {
      flutterSkywayPlatform = MockFlutterSkywayPlatform();
      FlutterSkywayPlatform.instance = flutterSkywayPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = '__test_platform__';
        when(
          () => flutterSkywayPlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        final actualPlatformName = await SkyWay.getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws exception when platform implementation is missing',
          () async {
        when(
          () => flutterSkywayPlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        expect(SkyWay.getPlatformName(), throwsException);
      });
    });
  });
}
