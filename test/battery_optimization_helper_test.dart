import 'package:flutter_test/flutter_test.dart';
import 'package:battery_optimization_helper/battery_optimization_helper_platform_interface.dart';
import 'package:battery_optimization_helper/battery_optimization_helper_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBatteryOptimizationHelperPlatform
    with MockPlatformInterfaceMixin
    implements BatteryOptimizationHelperPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BatteryOptimizationHelperPlatform initialPlatform =
      BatteryOptimizationHelperPlatform.instance;

  test('$MethodChannelBatteryOptimizationHelper is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelBatteryOptimizationHelper>(),
    );
  });
}
