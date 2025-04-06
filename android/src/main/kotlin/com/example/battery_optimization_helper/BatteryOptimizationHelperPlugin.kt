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
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BatteryOptimizationHelperPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private var activity: Activity? = null

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
    val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
    when (call.method) {
        "isBatteryOptimizationEnabled" -> {
            val isEnabled = !powerManager.isIgnoringBatteryOptimizations(context.packageName)
            result.success(isEnabled)
        }
        "requestDisableBatteryOptimization" -> {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
            intent.data = Uri.parse("package:${context.packageName}")
            activity?.startActivity(intent)
            result.success(null)
        }
        "openBatteryOptimizationSettings" -> {
            val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
            activity?.startActivity(intent)
            result.success(null)
        }
        "openAutoStartSettings" -> {
            val opened = activity?.let { openAutoStartSettings(it) } ?: false
            result.success(opened)
        }
        else -> result.notImplemented()
    }
  }


  fun openAutoStartSettings(context: Context): Boolean {
    val intent = Intent()
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

    val manufacturer = Build.MANUFACTURER.lowercase()
    when (manufacturer) {
        "xiaomi" -> {
            intent.component = ComponentName(
                "com.miui.securitycenter",
                "com.miui.permcenter.autostart.AutoStartManagementActivity"
            )
        }
        "oppo" -> {
            intent.component = ComponentName(
                "com.coloros.safecenter",
                "com.coloros.safecenter.startupapp.StartupAppListActivity"
            )
        }
        "vivo" -> {
            intent.component = ComponentName(
                "com.vivo.permissionmanager",
                "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"
            )
        }
        "letv" -> {
            intent.component = ComponentName(
                "com.letv.android.letvsafe",
                "com.letv.android.letvsafe.AutobootManageActivity"
            )
        }
        "honor" -> {
            intent.component = ComponentName(
                "com.huawei.systemmanager",
                "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
            )
        }
        else -> {
            return false
        }
    }

    return try {
        context.startActivity(intent)
        true
    } catch (e: Exception) {
        false
    }
  }

}
