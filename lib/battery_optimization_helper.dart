import 'dart:async';

import 'package:flutter/services.dart';

import 'battery_optimization_helper_platform_interface.dart';

/// Public API for interacting with Android battery optimization.
///
/// These methods are safe to call on any platform; on unsupported
/// platforms or older Android versions, they no-op or return defaults.
class BatteryOptimizationHelper {
  static BatteryOptimizationHelperPlatform get _platform =>
      BatteryOptimizationHelperPlatform.instance;

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
    final optimized = await isBatteryOptimizationEnabled();
    if (!optimized) return true; // already good

    try {
      // Prefer result-based flow if available
      try {
        final disabled =
            await _platform.requestDisableBatteryOptimizationWithResult();
        if (disabled) return true;
      } on UnimplementedError {
        // Older platform: fire-and-forget
        await _platform.requestDisableBatteryOptimization();
      }

      // Re-check after returning from the dialog or fallback
      final nowOptimized = await isBatteryOptimizationEnabled();
      if (!nowOptimized) return true;

    } on PlatformException {
      if (openSettingsIfDirectRequestNotPossible) {
        try {
          await _platform.openBatteryOptimizationSettings();
          return true;
        } catch (_) {
          return false;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
    // If still optimized, optionally open settings
    if (openSettingsIfDirectRequestNotPossible) {
      try {
        await _platform.openBatteryOptimizationSettings();
        return true;
      } catch (_) {}
    }
    return false;
  }
}
