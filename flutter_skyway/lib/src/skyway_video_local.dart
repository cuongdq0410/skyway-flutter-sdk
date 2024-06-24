import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Local video view
class SkywayVideoLocal extends StatelessWidget {
  /// Constructor
  const SkywayVideoLocal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const androidViewType = 'flutter_skyway_android/local_renderer';
    const iOSViewType = 'flutter_skyway_ios/local_renderer';
    // Pass parameters to the platform side.
    const creationParams = <String, dynamic>{};

    // Pass parameters to the platform side.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: androidViewType,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          );
        },
        onCreatePlatformView: (params) {
          return PlatformViewsService.initExpensiveAndroidView(
            id: params.id,
            viewType: androidViewType,
            layoutDirection: TextDirection.ltr,
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: iOSViewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return Text('$defaultTargetPlatform is not yet supported by this plugin.');
  }

  ///
  Future<void> onPlatformViewCreated(int id) async {}
}
