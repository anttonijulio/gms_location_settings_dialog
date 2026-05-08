# gms_location_settings_dialog

A Flutter plugin that shows the Google Play Services in-app location settings dialog on Android — the dialog with a GPS toggle that appears **inside the app**, without redirecting the user to system Settings.

On iOS, no equivalent API exists; the plugin reports the current `CLLocationManager.locationServicesEnabled()` value with no dialog.

> **Scope:** This plugin does one thing — show the GMS location settings dialog. It does not request location permission. Use `permission_handler` or `geolocator` for that.

---

## Platform behavior

| Platform | Behavior |
|---|---|
| Android (GMS) | Shows the `ResolvableApiException` dialog with a GPS toggle. Returns `true` if the user enables location, `false` if they dismiss. |
| iOS | No in-app dialog available. Returns the current `CLLocationManager.locationServicesEnabled()` value immediately. |
| Web / Desktop | Not implemented. `show()` returns `false` silently. |

---

## Requirements

| | Minimum |
|---|---|
| Flutter | 3.10.0 |
| Dart | 3.0.0 |
| Android `minSdk` | 21 (Android 5.0 Lollipop) |
| Android | Google Play Services must be installed on device |
| iOS | 12.0 |

> **Huawei / GMS-less devices:** This plugin depends on `play-services-location:21.3.0`. On devices without Google Play Services (Huawei HMS, custom ROMs, some emulators), `show()` returns `false` because the GMS settings client is unavailable.

> **Vendor dialog behavior:** Even on GMS devices, the exact appearance and behavior of the dialog may vary across Android versions and device manufacturers (Samsung One UI, MIUI, ColorOS, etc.). The plugin guarantees the GMS API call — not identical dialog UX across all vendors.

---

## Installation

### 1. Add dependency

**From GitHub:**

```yaml
dependencies:
  gms_location_settings_dialog:
    git:
      url: https://github.com/anttonijulio/gms_location_settings_dialog
      ref: main
```

**From local path:**

```yaml
dependencies:
  gms_location_settings_dialog:
    path: ../gms_location_settings_dialog
```

### 2. Android — no additional setup required

The plugin registers itself automatically via Flutter's plugin system. No changes needed to `MainActivity.kt`.

The `play-services-location` dependency is declared inside the plugin's own `build.gradle` and resolved automatically by Gradle.

### 3. iOS — no additional setup required

The plugin registers itself via CocoaPods. No changes needed to `AppDelegate.swift`.

If your app requests location permission, add `NSLocationWhenInUseUsageDescription` to `ios/Runner/Info.plist` (required by Apple regardless of which plugin you use):

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to ...</string>
```

---

## Usage

```dart
import 'package:gms_location_settings_dialog/gms_location_settings_dialog.dart';

final dialog = GmsLocationSettingsDialog();

Future<void> ensureLocationEnabled() async {
  final enabled = await dialog.show();

  if (enabled) {
    // GPS is on — proceed
  } else {
    // User dismissed or GPS could not be enabled
  }
}
```

### Typical usage with `geolocator`

`show()` fills the gap that `geolocator` leaves — it activates the GPS hardware before you request the runtime permission:

```dart
Future<void> initLocation() async {
  // Step 1: ensure GPS hardware is on (this plugin)
  final serviceEnabled = await GmsLocationSettingsDialog().show();
  if (!serviceEnabled) return;

  // Step 2: ensure runtime permission is granted (geolocator)
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
  }

  // Step 3: get position
  final position = await Geolocator.getCurrentPosition();
}
```

---

## API

### `GmsLocationSettingsDialog()`

Default constructor. Stateless — safe to instantiate once and reuse, or create per-call.

---

### `Future<bool> show()`

Shows the GMS location settings dialog and returns whether location services are enabled after resolution.

**Returns:**
- `true` — location services are enabled (either were already on, or user enabled them via the dialog)
- `false` — user dismissed the dialog, GMS unavailable, activity not attached, or any error occurred

**Throws:** nothing — all `PlatformException` and `MissingPluginException` are caught internally and return `false`.

**Error codes** (caught internally, never rethrown):

| Code | Cause |
|---|---|
| `ALREADY_PENDING` | `show()` called again while a previous dialog is still open |
| `NO_ACTIVITY` | Plugin called before the Flutter activity is attached (e.g. during app startup) |

---

## Limitations

- **One call at a time (Android):** Calling `show()` while a dialog is already visible returns `false` immediately (`ALREADY_PENDING`). Await the first call before calling again.
- **No dialog on iOS:** Apple provides no API for an in-app GPS toggle. `show()` only reads the current state.
- **GMS required on Android:** Returns `false` on Huawei HMS devices and any device without Google Play Services.
- **Vendor inconsistency:** Dialog appearance and behavior may vary across Samsung, Xiaomi, OPPO, Vivo, and other Android skins. The GMS API call is consistent; the rendered dialog is not guaranteed to look or behave identically on all devices.
- **Web / macOS / Windows / Linux:** Not implemented — `show()` returns `false`.
- **Permission not included:** This plugin only toggles the GPS hardware switch. Runtime location permission (`ACCESS_FINE_LOCATION` / `NSLocationWhenInUseUsageDescription`) must be handled separately.

---

## License

MIT
