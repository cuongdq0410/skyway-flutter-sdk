import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Remote video view
class SkywayVideoRemote extends StatelessWidget {
  /// Constructor
  const SkywayVideoRemote({
    required this.memberId,
    super.key,
  });

  /// Remote member id
  final String memberId;

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    final androidViewType = 'flutter_skyway_android/remote_renderer/$memberId';
    final iOSViewType = 'flutter_skyway_ios/remote_renderer/$memberId';
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
