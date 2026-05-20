import 'package:flutter/services.dart';

class GmsLocationSettingsDialog {
  GmsLocationSettingsDialog();

  static const MethodChannel _channel = MethodChannel(
    'gms_location_settings_dialog/settings',
  );

  /// Shows the Google Play Services in-app location settings dialog (Android).
  ///
  /// On Android, uses GMS [ResolvableApiException] to present a dialog with a
  /// GPS toggle — no redirect to system Settings. Returns `true` when location
  /// services end up enabled after the dialog is resolved.
  ///
  /// If [fallback] is `true` (default) and GMS cannot show the dialog (e.g.
  /// device does not support it), the user is redirected to the system location
  /// settings screen instead, and `false` is returned.
  ///
  /// On iOS there is no equivalent in-app dialog. When [fallback] is `true`
  /// (default) and location services are disabled, the user is redirected to
  /// the app's Settings page so they can grant location permission. Returns the
  /// current [CLLocationManager.locationServicesEnabled] value.
  ///
  /// On unsupported platforms (Web, Desktop) returns `false`.
  Future<bool> show({bool fallback = true}) async {
    try {
      final enabled = await _channel.invokeMethod<bool>(
        'show',
        {'fallback': fallback},
      );
      return enabled ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
