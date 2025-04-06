# 🔋 battery_optimization_helper

A Flutter plugin to detect and request disabling Android's battery optimization for apps that require background activity or uninterrupted execution.

---

## ✨ Features

- ✅ Check if battery optimization is enabled
- ⚙️ Request user to disable battery optimization
- 📱 Open battery optimization settings screen
- 📱 Open Background autostart settings screen
- 🚫 Android-only (Android 6.0+)

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  battery_optimization_helper: ^latest
  ```

Then run:

```
flutter pub get
```

In your app's AndroidManifest.xml, add:

```
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>

```

## 🧪 Usage

```
import 'package:battery_optimization_helper/battery_optimization_helper.dart';

void checkBatteryOptimization() async {
  bool isEnabled = await BatteryOptimizationHelper.isBatteryOptimizationEnabled();
  print("Battery optimization is enabled: $isEnabled");
}

void requestToDisable() async {
  await BatteryOptimizationHelper.requestDisableBatteryOptimization();
}

void openSettings() async {
  await BatteryOptimizationHelper.openBatteryOptimizationSettings();
}

void openbackgroundSettings() async {
  await BatteryOptimizationHelper.openAutoStartSettings();
}
```# battery_optimization_helper
# battery_optimization_helper
