package com.example.battery_optimization_helper

import android.os.Build
import android.content.ComponentName
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BatteryOptimizationHelperPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private var activity: Activity? = null
  private var pendingResult: MethodChannel.Result? = null
  private val REQUEST_IGNORE_BATTERY_CODE = 9001

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "battery_optimization_helper")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
        "isBatteryOptimizationEnabled" -> {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
                val isEnabled = !powerManager.isIgnoringBatteryOptimizations(context.packageName)
                result.success(isEnabled)
            } else {
                // Battery optimizations were introduced in Android M (23).
                // Treat as not enabled on older versions to avoid crashes.
                result.success(false)
            }
        }
        "requestDisableBatteryOptimization" -> {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:${context.packageName}")
                }
                tryStartActivity(intent)
            }
            result.success(null)
        }
        "requestDisableBatteryOptimizationWithResult" -> {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (pendingResult != null) {
                    result.error("in_progress", "Another request is in progress", null)
                    return
                }
                val act = activity
                if (act == null) {
                    // No activity; best-effort check current state
                    val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
                    val disabled = pm.isIgnoringBatteryOptimizations(context.packageName)
                    result.success(disabled)
                    return
                }
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:${context.packageName}")
                }
                pendingResult = result
                try {
                    act.startActivityForResult(intent, REQUEST_IGNORE_BATTERY_CODE)
                } catch (_: Exception) {
                    pendingResult = null
                    // Fallback: just report current value
                    val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
                    val disabled = pm.isIgnoringBatteryOptimizations(context.packageName)
                    result.success(disabled)
                }
            } else {
                // Pre-M: not applicable, treat as disabled already
                result.success(true)
            }
        }
        "openBatteryOptimizationSettings" -> {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                tryStartActivity(intent)
            } else {
                // Fallback to app details on pre-M
                openAppDetailsSettings()
            }
            result.success(null)
        }
        "openAutoStartSettings" -> {
            val opened = openAutoStartSettings(context)
            result.success(opened)
        }
        else -> result.notImplemented()
    }
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == REQUEST_IGNORE_BATTERY_CODE) {
      val res = pendingResult
      pendingResult = null
      if (res != null) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
          val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
          val disabled = pm.isIgnoringBatteryOptimizations(context.packageName)
          res.success(disabled)
        } else {
          res.success(true)
        }
      }
      return true
    }
    return false
  }

  private fun tryStartActivity(intent: Intent) {
    try {
      activity?.startActivity(intent) ?: run {
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
      }
    } catch (_: Exception) {
      // Fallback to app details if the target activity doesn't exist
      openAppDetailsSettings()
    }
  }

  private fun openAppDetailsSettings() {
    val uri = Uri.parse("package:${context.packageName}")
    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, uri).apply {
      addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    }
    try {
      context.startActivity(intent)
    } catch (_: Exception) {
      // no-op
    }
  }

  fun openAutoStartSettings(context: Context): Boolean {
    val candidates = mutableListOf<Intent>()

    val manufacturer = Build.MANUFACTURER.lowercase()

    // Common vendor-specific launchers for auto-start/background settings
    when (manufacturer) {
      "xiaomi" -> {
        candidates += Intent().apply {
          component = ComponentName(
            "com.miui.securitycenter",
            "com.miui.permcenter.autostart.AutoStartManagementActivity"
          )
        }
        candidates += Intent().apply {
          component = ComponentName(
            "com.miui.securitycenter",
            "com.miui.permcenter.permissions.PermissionsEditorActivity"
          )
        }
      }
      "oppo", "realme" -> {
        candidates += Intent().apply {
          component = ComponentName(
            "com.coloros.safecenter",
            "com.coloros.safecenter.startupapp.StartupAppListActivity"
          )
        }
        candidates += Intent().apply {
          component = ComponentName(
            "com.oppo.safe",
            "com.oppo.safe.permission.startup.StartupAppListActivity"
          )
        }
      }
      "vivo" -> {
        candidates += Intent().apply {
          component = ComponentName(
            "com.vivo.permissionmanager",
            "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"
          )
        }
      }
      "huawei", "honor" -> {
        candidates += Intent().apply {
          component = ComponentName(
            "com.huawei.systemmanager",
            "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
          )
        }
        candidates += Intent().apply {
          component = ComponentName(
            "com.huawei.systemmanager",
            "com.huawei.systemmanager.optimize.bootstart.BootStartActivity"
          )
        }
      }
      "samsung" -> {
        candidates += Intent().apply {
          component = ComponentName(
            "com.samsung.android.lool",
            "com.samsung.android.sm.ui.battery.BatteryActivity"
          )
        }
        candidates += Intent().apply {
          component = ComponentName(
            "com.samsung.android.sm",
            "com.samsung.android.sm.ui.battery.BatteryActivity"
          )
        }
        candidates += Intent().apply {
          component = ComponentName(
            "com.samsung.android.sm",
            "com.samsung.android.sm.app.dashboard.SmartManagerDashBoardActivity"
          )
        }
      }
      "oneplus" -> {
        candidates += Intent().apply {
          component = ComponentName(
            "com.oneplus.security",
            "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"
          )
        }
        candidates += Intent().apply {
          component = ComponentName(
            "com.oneplus.security",
            "com.oneplus.security.chainlaunch.view.ChainLaunchSettings"
          )
        }
      }
      "asus" -> {
        candidates += Intent().apply {
          component = ComponentName(
            "com.asus.mobilemanager",
            "com.asus.mobilemanager.MainActivity"
          )
        }
      }
      "meizu" -> {
        candidates += Intent().apply {
          component = ComponentName(
            "com.meizu.safe",
            "com.meizu.safe.permission.SmartBGActivity"
          )
        }
      }
      "letv" -> {
        candidates += Intent().apply {
          component = ComponentName(
            "com.letv.android.letvsafe",
            "com.letv.android.letvsafe.AutobootManageActivity"
          )
        }
      }
      "nokia" -> {
        candidates += Intent().apply {
          component = ComponentName(
            "com.evenwell.powersaving.g3",
            "com.evenwell.powersaving.g3.exception.PowerSaverExceptionActivity"
          )
        }
      }
      "motorola" -> {
        candidates += Intent().apply {
          component = ComponentName(
            "com.motorola.ccc",
            "com.motorola.ccc.settings.optimize.ProcessManager"
          )
        }
      }
      else -> {
        // no vendor-specific candidate
      }
    }

    // Generic fallbacks
    candidates += Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
      data = Uri.parse("package:${context.packageName}")
    }
    candidates += Intent(Settings.ACTION_SETTINGS)

    for (intent in candidates) {
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      try {
        context.startActivity(intent)
        return true
      } catch (_: Exception) {
        // try next
      }
    }

    return false
  }

}
