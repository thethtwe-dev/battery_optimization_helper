import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'battery_optimization_helper_method_channel.dart';

abstract class BatteryOptimizationHelperPlatform extends PlatformInterface {
  BatteryOptimizationHelperPlatform() : super(token: _token);

  static final Object _token = Object();

  static BatteryOptimizationHelperPlatform _instance =
      MethodChannelBatteryOptimizationHelper();

  static BatteryOptimizationHelperPlatform get instance => _instance;

  static set instance(BatteryOptimizationHelperPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> isBatteryOptimizationEnabled() {
    throw UnimplementedError(
      'isBatteryOptimizationEnabled() has not been implemented.',
    );
  }

  Future<void> requestDisableBatteryOptimization() {
    throw UnimplementedError(
      'requestDisableBatteryOptimization() has not been implemented.',
    );
  }

  /// Attempts to request disabling battery optimization and completes
  /// after the user returns from the system dialog, reporting whether
  /// optimizations are now disabled (ignored) for the app.
  Future<bool> requestDisableBatteryOptimizationWithResult() {
    throw UnimplementedError(
      'requestDisableBatteryOptimizationWithResult() has not been implemented.',
    );
  }

  Future<void> openBatteryOptimizationSettings() {
    throw UnimplementedError(
      'openBatteryOptimizationSettings() has not been implemented.',
    );
  }

  Future<bool> openAutoStartSettings() {
    throw UnimplementedError(
      'openAutoStartSettings() has not been implemented.',
    );
  }

  Future<Map<String, dynamic>> getBatteryRestrictionSnapshot() {
    throw UnimplementedError(
      'getBatteryRestrictionSnapshot() has not been implemented.',
    );
  }
}
