import 'dart:io' show Platform;

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
  /// On iOS there is no equivalent API — returns the current
  /// [CLLocationManager.locationServicesEnabled] value immediately, no dialog.
  ///
  /// On unsupported platforms (Web, Desktop) returns `false`.
  Future<bool> show() async {
    try {
      final enabled = await _channel.invokeMethod<bool>('show');
      return enabled ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
