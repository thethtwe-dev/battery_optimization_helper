import 'package:battery_optimization_helper/battery_optimization_helper.dart';
import 'package:battery_optimization_helper/battery_optimization_helper_method_channel.dart';
import 'package:battery_optimization_helper/battery_optimization_helper_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakeBatteryOptimizationHelperPlatform
    with MockPlatformInterfaceMixin
    implements BatteryOptimizationHelperPlatform {
  FakeBatteryOptimizationHelperPlatform({
    required this.snapshot,
    this.isOptimizationEnabledValue = false,
    this.requestWithResultValue = true,
    this.throwOnRequestWithResult = false,
    this.throwOnOpenSettings = false,
  });

  final Map<String, dynamic> snapshot;
  final bool isOptimizationEnabledValue;
  final bool requestWithResultValue;
  final bool throwOnRequestWithResult;
  final bool throwOnOpenSettings;

  bool openSettingsCalled = false;

  @override
  Future<Map<String, dynamic>> getBatteryRestrictionSnapshot() async =>
      snapshot;

  @override
  Future<bool> isBatteryOptimizationEnabled() async =>
      isOptimizationEnabledValue;

  @override
  Future<void> openBatteryOptimizationSettings() async {
    openSettingsCalled = true;
    if (throwOnOpenSettings) {
      throw PlatformException(code: 'open_failed');
    }
  }

  @override
  Future<bool> openAutoStartSettings() async => true;

  @override
  Future<void> requestDisableBatteryOptimization() async {}

  @override
  Future<bool> requestDisableBatteryOptimizationWithResult() async {
    if (throwOnRequestWithResult) {
      throw PlatformException(code: 'request_failed');
    }
    return requestWithResultValue;
  }
}

void main() {
  final initialPlatform = BatteryOptimizationHelperPlatform.instance;

  tearDown(() {
    BatteryOptimizationHelperPlatform.instance = initialPlatform;
  });

  test('$MethodChannelBatteryOptimizationHelper is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelBatteryOptimizationHelper>(),
    );
  });

  test('getBatteryRestrictionSnapshot returns typed diagnostics', () async {
    final fake = FakeBatteryOptimizationHelperPlatform(
      snapshot: <String, dynamic>{
        'isSupported': true,
        'androidSdkInt': 34,
        'manufacturer': 'samsung',
        'isBatteryOptimizationEnabled': true,
        'isPowerSaveModeOn': true,
        'canOpenAutoStartSettings': false,
      },
    );
    BatteryOptimizationHelperPlatform.instance = fake;

    final snapshot =
        await BatteryOptimizationHelper.getBatteryRestrictionSnapshot();

    expect(snapshot.isSupported, true);
    expect(snapshot.androidSdkInt, 34);
    expect(snapshot.manufacturer, 'samsung');
    expect(snapshot.isBatteryOptimizationEnabled, true);
    expect(snapshot.isPowerSaveModeOn, true);
    expect(snapshot.canOpenAutoStartSettings, false);
  });

  test(
    'ensureOptimizationDisabledDetailed returns unsupported on non-Android',
    () async {
      final fake = FakeBatteryOptimizationHelperPlatform(
        snapshot: <String, dynamic>{'isSupported': false},
      );
      BatteryOptimizationHelperPlatform.instance = fake;

      final outcome =
          await BatteryOptimizationHelper.ensureOptimizationDisabledDetailed();

      expect(outcome.status, OptimizationOutcomeStatus.unsupported);
      expect(outcome.isOptimizationDisabled, true);
      expect(outcome.succeeded, true);
    },
  );

  test('ensureOptimizationDisabledDetailed returns alreadyDisabled', () async {
    final fake = FakeBatteryOptimizationHelperPlatform(
      snapshot: <String, dynamic>{
        'isSupported': true,
        'isBatteryOptimizationEnabled': false,
      },
    );
    BatteryOptimizationHelperPlatform.instance = fake;

    final outcome =
        await BatteryOptimizationHelper.ensureOptimizationDisabledDetailed();

    expect(outcome.status, OptimizationOutcomeStatus.alreadyDisabled);
    expect(outcome.isOptimizationDisabled, true);
  });

  test(
    'ensureOptimizationDisabledDetailed returns disabledAfterPrompt',
    () async {
      final fake = FakeBatteryOptimizationHelperPlatform(
        snapshot: <String, dynamic>{
          'isSupported': true,
          'isBatteryOptimizationEnabled': true,
        },
        requestWithResultValue: true,
      );
      BatteryOptimizationHelperPlatform.instance = fake;

      final outcome =
          await BatteryOptimizationHelper.ensureOptimizationDisabledDetailed();

      expect(outcome.status, OptimizationOutcomeStatus.disabledAfterPrompt);
      expect(outcome.isOptimizationDisabled, true);
    },
  );

  test(
    'ensureOptimizationDisabledDetailed opens settings on request failure',
    () async {
      final fake = FakeBatteryOptimizationHelperPlatform(
        snapshot: <String, dynamic>{
          'isSupported': true,
          'isBatteryOptimizationEnabled': true,
        },
        throwOnRequestWithResult: true,
      );
      BatteryOptimizationHelperPlatform.instance = fake;

      final outcome =
          await BatteryOptimizationHelper.ensureOptimizationDisabledDetailed();

      expect(outcome.status, OptimizationOutcomeStatus.settingsOpened);
      expect(outcome.isOptimizationDisabled, false);
      expect(fake.openSettingsCalled, true);
    },
  );

  test(
    'legacy ensureOptimizationDisabled returns false when still enabled',
    () async {
      final fake = FakeBatteryOptimizationHelperPlatform(
        snapshot: <String, dynamic>{
          'isSupported': true,
          'isBatteryOptimizationEnabled': true,
        },
        isOptimizationEnabledValue: true,
        requestWithResultValue: false,
      );
      BatteryOptimizationHelperPlatform.instance = fake;

      final ok = await BatteryOptimizationHelper.ensureOptimizationDisabled(
        openSettingsIfDirectRequestNotPossible: false,
      );

      expect(ok, false);
    },
  );
}
