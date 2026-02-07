import 'dart:async';

import 'package:flutter/services.dart';

import 'battery_optimization_helper_platform_interface.dart';

/// Typed status for battery optimization disable attempts.
enum OptimizationOutcomeStatus {
  alreadyDisabled,
  disabledAfterPrompt,
  settingsOpened,
  unsupported,
  failed,
}

/// Typed outcome returned by [BatteryOptimizationHelper.ensureOptimizationDisabledDetailed].
class OptimizationOutcome {
  const OptimizationOutcome({
    required this.status,
    required this.isOptimizationDisabled,
  });

  final OptimizationOutcomeStatus status;

  /// Current known optimization state when the call completes.
  final bool isOptimizationDisabled;

  bool get succeeded => status != OptimizationOutcomeStatus.failed;
}

/// Diagnostic snapshot of current battery-related restrictions.
class BatteryRestrictionSnapshot {
  const BatteryRestrictionSnapshot({
    required this.isSupported,
    required this.androidSdkInt,
    required this.manufacturer,
    required this.isBatteryOptimizationEnabled,
    required this.isPowerSaveModeOn,
    required this.canOpenAutoStartSettings,
  });

  factory BatteryRestrictionSnapshot.fromMap(Map<String, dynamic> map) {
    return BatteryRestrictionSnapshot(
      isSupported: _asBool(map['isSupported']),
      androidSdkInt: _asInt(map['androidSdkInt']),
      manufacturer: _asString(map['manufacturer']),
      isBatteryOptimizationEnabled: _asBool(
        map['isBatteryOptimizationEnabled'],
      ),
      isPowerSaveModeOn: _asBool(map['isPowerSaveModeOn']),
      canOpenAutoStartSettings: _asBool(map['canOpenAutoStartSettings']),
    );
  }

  const BatteryRestrictionSnapshot.unsupported()
    : isSupported = false,
      androidSdkInt = null,
      manufacturer = 'unknown',
      isBatteryOptimizationEnabled = false,
      isPowerSaveModeOn = false,
      canOpenAutoStartSettings = false;

  final bool isSupported;
  final int? androidSdkInt;
  final String manufacturer;
  final bool isBatteryOptimizationEnabled;
  final bool isPowerSaveModeOn;
  final bool canOpenAutoStartSettings;

  static bool _asBool(dynamic value) => value is bool ? value : false;

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _asString(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    return 'unknown';
  }
}

/// Public API for interacting with Android battery optimization.
///
/// These methods are safe to call on any platform; on unsupported
/// platforms or older Android versions, they no-op or return defaults.
class BatteryOptimizationHelper {
  static BatteryOptimizationHelperPlatform get _platform =>
      BatteryOptimizationHelperPlatform.instance;

  /// Returns current device/platform diagnostics for battery restrictions.
  static Future<BatteryRestrictionSnapshot>
  getBatteryRestrictionSnapshot() async {
    try {
      final map = await _platform.getBatteryRestrictionSnapshot();
      return BatteryRestrictionSnapshot.fromMap(map);
    } on PlatformException {
      return const BatteryRestrictionSnapshot.unsupported();
    } catch (_) {
      return const BatteryRestrictionSnapshot.unsupported();
    }
  }

  /// Returns true if system battery optimization is currently enabled
  /// for the app (i.e., not whitelisted/ignoring optimizations).
  static Future<bool> isBatteryOptimizationEnabled() async {
    try {
      return await _platform.isBatteryOptimizationEnabled();
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Attempts to show the system dialog to whitelist the app from
  /// battery optimizations (Android 6.0+).
  static Future<void> requestDisableBatteryOptimization() async {
    try {
      await _platform.requestDisableBatteryOptimization();
    } catch (_) {
      // no-op
    }
  }

  /// Opens the system battery optimization settings screen where users
  /// can manage per-app optimization rules.
  static Future<void> openBatteryOptimizationSettings() async {
    try {
      await _platform.openBatteryOptimizationSettings();
    } catch (_) {
      // no-op
    }
  }

  /// Best-effort attempt to open OEM-specific auto-start/background settings.
  /// Returns true if a screen was opened, false otherwise.
  static Future<bool> openAutoStartSettings() async {
    try {
      return await _platform.openAutoStartSettings();
    } catch (_) {
      return false;
    }
  }

  /// Convenience helper: if optimization is enabled, try to request disabling it.
  /// Returns true if it's already disabled or the request/settings screen was invoked.
  static Future<bool> ensureOptimizationDisabled({
    bool openSettingsIfDirectRequestNotPossible = true,
  }) async {
    final outcome = await ensureOptimizationDisabledDetailed(
      openSettingsIfDirectRequestNotPossible:
          openSettingsIfDirectRequestNotPossible,
    );
    return outcome.succeeded;
  }

  /// Typed variant of [ensureOptimizationDisabled] with explicit outcome status.
  static Future<OptimizationOutcome> ensureOptimizationDisabledDetailed({
    bool openSettingsIfDirectRequestNotPossible = true,
  }) async {
    final snapshot = await getBatteryRestrictionSnapshot();
    if (!snapshot.isSupported) {
      return const OptimizationOutcome(
        status: OptimizationOutcomeStatus.unsupported,
        isOptimizationDisabled: true,
      );
    }

    if (!snapshot.isBatteryOptimizationEnabled) {
      return const OptimizationOutcome(
        status: OptimizationOutcomeStatus.alreadyDisabled,
        isOptimizationDisabled: true,
      );
    }

    try {
      // Prefer result-based flow if available.
      try {
        final disabled =
            await _platform.requestDisableBatteryOptimizationWithResult();
        if (disabled) {
          return const OptimizationOutcome(
            status: OptimizationOutcomeStatus.disabledAfterPrompt,
            isOptimizationDisabled: true,
          );
        }
      } on UnimplementedError {
        // Older platform: fall back to fire-and-forget and re-check.
        await _platform.requestDisableBatteryOptimization();
      }

      final nowOptimized = await isBatteryOptimizationEnabled();
      if (!nowOptimized) {
        return const OptimizationOutcome(
          status: OptimizationOutcomeStatus.disabledAfterPrompt,
          isOptimizationDisabled: true,
        );
      }
    } on PlatformException {
      if (openSettingsIfDirectRequestNotPossible) {
        try {
          await _platform.openBatteryOptimizationSettings();
          return const OptimizationOutcome(
            status: OptimizationOutcomeStatus.settingsOpened,
            isOptimizationDisabled: false,
          );
        } catch (_) {
          return const OptimizationOutcome(
            status: OptimizationOutcomeStatus.failed,
            isOptimizationDisabled: false,
          );
        }
      }
      return const OptimizationOutcome(
        status: OptimizationOutcomeStatus.failed,
        isOptimizationDisabled: false,
      );
    } catch (_) {
      return const OptimizationOutcome(
        status: OptimizationOutcomeStatus.failed,
        isOptimizationDisabled: false,
      );
    }

    if (openSettingsIfDirectRequestNotPossible) {
      try {
        await _platform.openBatteryOptimizationSettings();
        return const OptimizationOutcome(
          status: OptimizationOutcomeStatus.settingsOpened,
          isOptimizationDisabled: false,
        );
      } catch (_) {}
    }

    return const OptimizationOutcome(
      status: OptimizationOutcomeStatus.failed,
      isOptimizationDisabled: false,
    );
  }
}
