import 'package:flutter/services.dart';

class BatteryOptimizationHelper {
  static const MethodChannel _channel = MethodChannel(
    'battery_optimization_helper',
  );

  static Future<bool> isBatteryOptimizationEnabled() async {
    final bool isEnabled = await _channel.invokeMethod(
      'isBatteryOptimizationEnabled',
    );
    return isEnabled;
  }

  static Future<void> requestDisableBatteryOptimization() async {
    await _channel.invokeMethod('requestDisableBatteryOptimization');
  }

  static Future<void> openBatteryOptimizationSettings() async {
    await _channel.invokeMethod('openBatteryOptimizationSettings');
  }

  static Future<bool> openAutoStartSettings() async {
    return await _channel.invokeMethod('openAutoStartSettings');
  }
}
