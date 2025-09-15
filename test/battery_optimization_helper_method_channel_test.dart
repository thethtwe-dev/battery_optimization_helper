import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:battery_optimization_helper/battery_optimization_helper_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelBatteryOptimizationHelper();
  const channel = MethodChannel('battery_optimization_helper');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          switch (call.method) {
            case 'isBatteryOptimizationEnabled':
              return false;
            case 'requestDisableBatteryOptimizationWithResult':
              return true;
            case 'openAutoStartSettings':
              return true;
            case 'requestDisableBatteryOptimization':
            case 'openBatteryOptimizationSettings':
              return null;
            default:
              throw PlatformException(code: 'not_implemented');
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('isBatteryOptimizationEnabled returns false', () async {
    expect(await platform.isBatteryOptimizationEnabled(), false);
  });

  test('openAutoStartSettings returns true', () async {
    expect(await platform.openAutoStartSettings(), true);
  });

  test('requestDisableBatteryOptimizationWithResult returns true', () async {
    expect(await platform.requestDisableBatteryOptimizationWithResult(), true);
  });
}
