## 0.2.0

- Add typed optimization outcomes via `ensureOptimizationDisabledDetailed()` with explicit statuses (`alreadyDisabled`, `disabledAfterPrompt`, `settingsOpened`, `unsupported`, `failed`).
- Add diagnostics API: `getBatteryRestrictionSnapshot()` (SDK, manufacturer, optimization state, power saver state, and OEM settings capability).
- Update Android implementation to provide diagnostics and OEM capability checks.
- Expand tests and update example app to demonstrate the new APIs.
- Bump example Android NDK to `28.2.13676358` to match current `integration_test` requirements.
- Replace `com.example.*` Android package/application identifiers with project-specific namespaces.
- Align SDK constraints with current dependencies (`Dart >=3.8`, `Flutter >=3.32`).
- Add GitHub Actions CI workflow to enforce analyze/test/build and `publish --dry-run`.

## 0.1.4

- Upgrade lint/tooling constraints to current compatible versions (`flutter_lints` 6.x).
- Refresh example dependency lockfile and align it with the package version.
- Update example widget test to match current sample UI.

## 0.0.1

- Initial release.
- Added support for checking and requesting disable of Android battery optimization.

## 0.0.2

- Update readme file.

## 0.0.3

- Format dart files

## 0.0.4

- Added background autostart

## 0.0.5

- Update readme file.

## 0.1.0

- Add Android version guards to avoid crashes on API < 23.
- Improve activity launching with safe fallbacks.
- Expand OEM auto-start/background settings coverage (Samsung, Huawei, OnePlus, Realme, Asus, Meizu, Nokia, Motorola, etc.).
- Update README with clear usage, 16 KB page size guidance, and tips.
 - Refactor Dart API to use platform interface; add `ensureOptimizationDisabled()` convenience method and safer wrappers that handle exceptions.
 - Add `requestDisableBatteryOptimizationWithResult` to report status after user returns from the system dialog.
 - Bump Kotlin Gradle Plugin to 2.1.0 in example and 2.1.0 in plugin build to resolve upcoming support warnings.

## 0.1.1

- Improve README: installing via CLI, rationale example snippet, versions/tooling, and pub score tips.
- Enhance example app with rationale dialog and clearer actions.
- Update tests to reflect new API and stabilize Android unit test.

## 0.1.2

- Improve README: installing via CLI, rationale example snippet, versions/tooling, and pub score tips.
- Enhance example app with rationale dialog and clearer actions.
- Update tests to reflect new API and stabilize Android unit test.

## 0.1.3

- Improve README: installing via CLI, rationale example snippet, versions/tooling, and pub score tips.
- Enhance example app with rationale dialog and clearer actions.
- Update tests to reflect new API and stabilize Android unit test.
