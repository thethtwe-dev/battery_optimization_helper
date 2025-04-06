import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'battery_optimization_helper_method_channel.dart';

abstract class BatteryOptimizationHelperPlatform extends PlatformInterface {
  /// Constructs a BatteryOptimizationHelperPlatform.
  BatteryOptimizationHelperPlatform() : super(token: _token);

  static final Object _token = Object();

  static BatteryOptimizationHelperPlatform _instance =
      MethodChannelBatteryOptimizationHelper();

  /// The default instance of [BatteryOptimizationHelperPlatform] to use.
  ///
  /// Defaults to [MethodChannelBatteryOptimizationHelper].
  static BatteryOptimizationHelperPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BatteryOptimizationHelperPlatform] when
  /// they register themselves.
  static set instance(BatteryOptimizationHelperPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
