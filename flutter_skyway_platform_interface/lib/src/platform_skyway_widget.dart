import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

///
abstract class PlatformSkywayWidget extends PlatformInterface {

  /// Used by the platform implementation to create a new
  /// [PlatformSkywayWidget].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformSkywayWidget.implementation() : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformSkywayWidget].

  /// Builds a new View.
  ///
  /// Returns a Widget tree that embeds the created web view.
  Widget build(BuildContext context);
}
