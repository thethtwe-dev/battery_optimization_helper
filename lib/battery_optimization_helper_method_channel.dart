import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'battery_optimization_helper_platform_interface.dart';

/// MethodChannel implementation of [BatteryOptimizationHelperPlatform].
class MethodChannelBatteryOptimizationHelper
    extends BatteryOptimizationHelperPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('battery_optimization_helper');

  @override
  Future<bool> isBatteryOptimizationEnabled() async {
    final isEnabled = await methodChannel.invokeMethod<bool>(
      'isBatteryOptimizationEnabled',
    );
    return isEnabled ?? false;
  }

  @override
  Future<void> requestDisableBatteryOptimization() async {
    await methodChannel.invokeMethod<void>('requestDisableBatteryOptimization');
  }

  @override
  Future<bool> requestDisableBatteryOptimizationWithResult() async {
    final disabled = await methodChannel.invokeMethod<bool>(
      'requestDisableBatteryOptimizationWithResult',
    );
    return disabled ?? false;
  }

  @override
  Future<void> openBatteryOptimizationSettings() async {
    await methodChannel.invokeMethod<void>('openBatteryOptimizationSettings');
  }

  @override
  Future<bool> openAutoStartSettings() async {
    final opened = await methodChannel.invokeMethod<bool>(
      'openAutoStartSettings',
    );
    return opened ?? false;
  }

  @override
  Future<Map<String, dynamic>> getBatteryRestrictionSnapshot() async {
    final snapshot = await methodChannel.invokeMapMethod<String, dynamic>(
      'getBatteryRestrictionSnapshot',
    );
    return snapshot ?? <String, dynamic>{};
  }
}
