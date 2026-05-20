package com.example.gms_location_settings_dialog

import android.app.Activity
import android.content.Intent
import android.content.IntentSender
import android.provider.Settings
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationSettingsRequest
import com.google.android.gms.location.LocationSettingsStatusCodes
import com.google.android.gms.location.Priority
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class GmsLocationSettingsDialogPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null

    companion object {
        private const val CHANNEL = "gms_location_settings_dialog/settings"
        private const val REQUEST_CHECK_SETTINGS = 0xC0FE
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "show" -> showDialog(call, result)
            else -> result.notImplemented()
        }
    }

    private fun showDialog(call: MethodCall, result: Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }
        if (pendingResult != null) {
            result.error("ALREADY_PENDING", "A dialog is already showing", null)
            return
        }

        val fallback = call.argument<Boolean>("fallback") ?: true

        val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 10_000L)
            .build()

        val settingsRequest = LocationSettingsRequest.Builder()
            .addLocationRequest(locationRequest)
            .setAlwaysShow(true)
            .build()

        LocationServices.getSettingsClient(currentActivity)
            .checkLocationSettings(settingsRequest)
            .addOnSuccessListener {
                result.success(true)
            }
            .addOnFailureListener { exception ->
                if (exception is ResolvableApiException &&
                    exception.statusCode == LocationSettingsStatusCodes.RESOLUTION_REQUIRED
                ) {
                    try {
                        pendingResult = result
                        exception.startResolutionForResult(currentActivity, REQUEST_CHECK_SETTINGS)
                    } catch (_: IntentSender.SendIntentException) {
                        pendingResult = null
                        if (fallback) openLocationSettings(currentActivity)
                        result.success(false)
                    }
                } else {
                    if (fallback) openLocationSettings(currentActivity)
                    result.success(false)
                }
            }
    }

    private fun openLocationSettings(activity: Activity) {
        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        activity.startActivity(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_CHECK_SETTINGS) {
            pendingResult?.success(resultCode == Activity.RESULT_OK)
            pendingResult = null
            return true
        }
        return false
    }
}
