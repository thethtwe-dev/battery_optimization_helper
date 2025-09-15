# 🔋 battery_optimization_helper

Lightweight Flutter plugin to detect and request disabling Android battery optimization, with optional shortcuts to common OEM auto‑start/background settings.

## ✨ Features

- ✅ Check if battery optimization is enabled (Android 6.0+)
- ⚙️ Prompt user to allow “Ignore battery optimizations”
- ⚙️ Open system battery optimization settings
- 🚀 Try opening OEM auto‑start/background settings (best‑effort)
- 🔁 Result-based request: report status after user returns from the dialog

## 📦 Installing

Add to `pubspec.yaml`:

```yaml
dependencies:
  battery_optimization_helper: ^0.1.3
```

Or use the CLI:

```
flutter pub add battery_optimization_helper
```

Then run `flutter pub get` if needed.

The plugin declares `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`. If you prefer to declare it yourself, you can override or remove it using manifest merge rules in your app.

```xml
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>
```

## 🧪 Usage

```dart
import 'package:battery_optimization_helper/battery_optimization_helper.dart';

Future<void> example() async {
  final isEnabled = await BatteryOptimizationHelper.isBatteryOptimizationEnabled();
  if (isEnabled) {
    // Prefer the result-based flow
    final disabled = await BatteryOptimizationHelper
        .ensureOptimizationDisabled(openSettingsIfDirectRequestNotPossible: true);
  }

  // Open the system screen for battery optimizations
  await BatteryOptimizationHelper.openBatteryOptimizationSettings();

  // Best‑effort OEM background/auto‑start settings (may return false)
  final opened = await BatteryOptimizationHelper.openAutoStartSettings();
  if (!opened) {
    // Consider opening your own in‑app guidance
  }
}
```

Or, use the convenience helper to ensure optimization is disabled:

```dart
final ok = await BatteryOptimizationHelper.ensureOptimizationDisabled(
  openSettingsIfDirectRequestNotPossible: true,
);
```

If you need finer control, you can call the result-based method directly:

```dart
final disabled = await BatteryOptimizationHelperPlatform.instance
    .requestDisableBatteryOptimizationWithResult();
```

The example app includes a small “rationale” dialog flow you can adapt.

## 📚 Notes on Android versions

- Android < 6.0 (API < 23): Battery optimizations don’t apply. The API safely no‑ops and reports optimization as disabled.
- OEM auto‑start settings: Paths differ by device and may not exist. The plugin tries several well‑known targets and falls back to app settings.

## 🧰 Tooling

- Kotlin Gradle Plugin: 2.1.0+ recommended (the example uses 2.1.0).
- Android Gradle Plugin: 8.1+ recommended.
- Flutter: 3.13+ recommended.

## 📐 Android 16 KB page size support

Some newer Android devices use a 16 KB memory page size. Modern Flutter/AGP/NDK toolchains handle this automatically. Ensure your app uses:

- Flutter 3.13+ and Android Gradle Plugin 8.1+ (or newer)
- A recent NDK (example app uses `ndkVersion = 27.0.12077973`)

If you must support older build toolchains, a pragmatic workaround is to force extraction of native libraries to avoid direct APK mapping:

```xml
<application
  android:extractNativeLibs="true"
  ...>
  ...
</application>
```

Only use this workaround if you cannot update your build tooling, as it may increase install size/time. The example app in this repo is configured with a recent NDK and AGP and does not require the workaround.

## 🙋 Tips

- Explain clearly to users why disabling optimization is needed before showing the system dialog.
- Not all OEM settings pages are available; handle a `false` result from `openAutoStartSettings()` gracefully.

## 🔧 Example

See `example/` for a runnable app.

Quick rationale flow (adapt from the example app):

```dart
final proceed = await showDialog<bool>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('Background Execution'),
    content: const Text(
      'To run reliably in the background, the app requests an exception from '
      'battery optimizations. You can change this in system settings.',
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not now')),
      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
    ],
  ),
);
if (proceed == true) {
  final ok = await BatteryOptimizationHelper.ensureOptimizationDisabled(
    openSettingsIfDirectRequestNotPossible: true,
  );
  // handle ok
}
```

See full example at `example/lib/main.dart`.

## 🗞️ Changelog

See `CHANGELOG.md` for release notes.

## 📦 Versions

- Plugin: `>=0.1.3`
- Flutter: `>=3.13.0` recommended
- Android Gradle Plugin: `>=8.1.0` recommended
- Kotlin Gradle Plugin: `>=2.1.0` recommended