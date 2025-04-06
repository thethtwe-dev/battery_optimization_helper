import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'battery_optimization_helper_platform_interface.dart';

/// An implementation of [BatteryOptimizationHelperPlatform] that uses method channels.
class MethodChannelBatteryOptimizationHelper
    extends BatteryOptimizationHelperPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('battery_optimization_helper');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
