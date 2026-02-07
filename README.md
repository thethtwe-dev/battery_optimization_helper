# 🔋 battery_optimization_helper

Lightweight Flutter plugin to detect and request disabling Android battery optimization, with optional shortcuts to common OEM auto‑start/background settings.

## ✨ Features

- ✅ Check if battery optimization is enabled (Android 6.0+)
- ⚙️ Prompt user to allow “Ignore battery optimizations”
- ⚙️ Open system battery optimization settings
- 🚀 Try opening OEM auto‑start/background settings (best‑effort)
- 🔁 Typed outcome flow for disable requests
- 🩺 Diagnostics snapshot API for battery restrictions and device context

## 📦 Installing

Add to `pubspec.yaml`:

```yaml
dependencies:
  battery_optimization_helper: ^0.2.0
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
  final outcome = await BatteryOptimizationHelper
      .ensureOptimizationDisabledDetailed(
    openSettingsIfDirectRequestNotPossible: true,
  );

  if (outcome.status == OptimizationOutcomeStatus.settingsOpened) {
    // User was routed to settings. Re-check on resume if needed.
  }

  final snapshot = await BatteryOptimizationHelper.getBatteryRestrictionSnapshot();
  debugPrint('Manufacturer: ${snapshot.manufacturer}');
  debugPrint('Power saver: ${snapshot.isPowerSaveModeOn}');

  // Open the system screen for battery optimizations
  await BatteryOptimizationHelper.openBatteryOptimizationSettings();

  // Best‑effort OEM background/auto‑start settings (may return false)
  final opened = await BatteryOptimizationHelper.openAutoStartSettings();
  if (!opened) {
    // Consider opening your own in‑app guidance
  }
}
```

Typed outcome helper:

```dart
final outcome = await BatteryOptimizationHelper.ensureOptimizationDisabledDetailed(
  openSettingsIfDirectRequestNotPossible: true,
);

switch (outcome.status) {
  case OptimizationOutcomeStatus.alreadyDisabled:
  case OptimizationOutcomeStatus.disabledAfterPrompt:
    // Ready for background work
    break;
  case OptimizationOutcomeStatus.settingsOpened:
    // Ask user to return after adjusting settings
    break;
  case OptimizationOutcomeStatus.unsupported:
    // Not applicable on this platform/device
    break;
  case OptimizationOutcomeStatus.failed:
    // Graceful fallback
    break;
}
```

Diagnostics snapshot:

```dart
final snapshot = await BatteryOptimizationHelper.getBatteryRestrictionSnapshot();
// snapshot.androidSdkInt, snapshot.manufacturer,
// snapshot.isBatteryOptimizationEnabled, snapshot.isPowerSaveModeOn,
// snapshot.canOpenAutoStartSettings
```

If you need lower-level control, you can still call platform methods directly:

```dart
final disabled = await BatteryOptimizationHelperPlatform.instance
    .requestDisableBatteryOptimizationWithResult();
```

The example app includes a small “rationale” dialog flow you can adapt.

## 🔄 Migration to 0.2.0

`0.2.0` adds typed outcomes and diagnostics while keeping the old helper available.

- Existing API still works: `ensureOptimizationDisabled()` returns `bool`.
- Recommended API: `ensureOptimizationDisabledDetailed()` returns `OptimizationOutcome`.
- New diagnostics API: `getBatteryRestrictionSnapshot()`.

Before:

```dart
final ok = await BatteryOptimizationHelper.ensureOptimizationDisabled(
  openSettingsIfDirectRequestNotPossible: true,
);
if (ok) {
  // proceed
}
```

After (recommended):

```dart
final outcome = await BatteryOptimizationHelper.ensureOptimizationDisabledDetailed(
  openSettingsIfDirectRequestNotPossible: true,
);

if (outcome.status == OptimizationOutcomeStatus.disabledAfterPrompt ||
    outcome.status == OptimizationOutcomeStatus.alreadyDisabled) {
  // proceed
}
```

## 📚 Notes on Android versions

- Android < 6.0 (API < 23): Battery optimizations don’t apply. The API safely no‑ops and reports optimization as disabled.
- OEM auto‑start settings: Paths differ by device and may not exist. The plugin tries several well‑known targets and falls back to app settings.

## 🧰 Tooling

- Kotlin Gradle Plugin: 2.1.0+ recommended (the example uses 2.1.0).
- Android Gradle Plugin: 8.1+ recommended.
- Flutter: 3.32+ recommended.

## 📐 Android 16 KB page size support

Some newer Android devices use a 16 KB memory page size. Modern Flutter/AGP/NDK toolchains handle this automatically. Ensure your app uses:

- Flutter 3.32+ and Android Gradle Plugin 8.1+ (or newer)
- A recent NDK (example app uses `ndkVersion = 28.2.13676358`)

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
  final outcome = await BatteryOptimizationHelper.ensureOptimizationDisabledDetailed(
    openSettingsIfDirectRequestNotPossible: true,
  );
  // handle outcome.status
}
```

See full example at `example/lib/main.dart`.

## 🗞️ Changelog

See `CHANGELOG.md` for release notes.

## 📦 Versions

- Plugin: `>=0.2.0`
- Flutter: `>=3.32.0` recommended
- Android Gradle Plugin: `>=8.1.0` recommended
- Kotlin Gradle Plugin: `>=2.1.0` recommended
