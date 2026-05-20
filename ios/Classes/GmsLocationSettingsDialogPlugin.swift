import Flutter
import CoreLocation
import UIKit

public class GmsLocationSettingsDialogPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "gms_location_settings_dialog/settings",
            binaryMessenger: registrar.messenger()
        )
        let instance = GmsLocationSettingsDialogPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "show":
            let args = call.arguments as? [String: Any]
            let fallback = args?["fallback"] as? Bool ?? true
            // iOS has no in-app GPS enable dialog; report current state.
            // Dispatch off main thread — locationServicesEnabled() can block.
            DispatchQueue.global(qos: .userInitiated).async {
                let enabled = CLLocationManager.locationServicesEnabled()
                DispatchQueue.main.async {
                    if !enabled && fallback {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    result(enabled)
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
