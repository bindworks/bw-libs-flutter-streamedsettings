package eu.bindworks.bw_streamed_settings

import android.app.Activity
import android.app.Application
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Context.*
import android.content.Intent
import android.content.IntentFilter
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel


class BwStreamedSettingsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var _applicationContext: Context? = null

    private lateinit var methodChannel: MethodChannel

    private lateinit var gpsEventChannel: EventChannel
    private lateinit var powerSaveModeEventChannel: EventChannel
    private lateinit var bluetoothEventChannel: EventChannel

    private var gpsStreamHandler: BoolStreamHandler? = null
    private var powerSaveModeStreamHandler: BoolStreamHandler? = null
    private var bluetoothStreamHandler: BoolStreamHandler? = null

    override fun onDetachedFromActivity() {
        teardownStreams()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        teardownStreams()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        setUpStreams(binding.activity)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        setUpStreams(binding.activity)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            binding.activity.registerActivityLifecycleCallbacks(
                object : Application.ActivityLifecycleCallbacks {
                    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
                    override fun onActivityStarted(activity: Activity) {}
                    override fun onActivityPaused(activity: Activity) {}
                    override fun onActivityStopped(activity: Activity) {}
                    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
                    override fun onActivityDestroyed(activity: Activity) {}

                    override fun onActivityResumed(activity: Activity) {
                        // If user turn on Bluetooth, gps, etc. in device settings, and move back to the app, we want to be notified by this change
                        gpsStreamHandler?.sendEvent(isGpsEnabled(activity))
                        powerSaveModeStreamHandler?.sendEvent(isPowerSaveModeEnabled(activity))
                        bluetoothStreamHandler?.sendEvent(isBluetoothEnabled(activity))
                    }
                })
        }
    }

    private fun setUpStreams(activity: Activity) {
        gpsStreamHandler = BoolStreamHandler(
            activity, "android.location.MODE_CHANGED",
            onSystemEvent = { context: Context ->
                gpsStreamHandler?.sendEvent(isGpsEnabled(context))
            })

        powerSaveModeStreamHandler =
            BoolStreamHandler(
                activity, "android.os.action.POWER_SAVE_MODE_CHANGED",
                onSystemEvent =
                { context: Context ->
                    powerSaveModeStreamHandler?.sendEvent(isPowerSaveModeEnabled(context))
                })

        bluetoothStreamHandler = BoolStreamHandler(
            activity, BluetoothAdapter.ACTION_STATE_CHANGED,
            onSystemEvent = { context: Context ->
                bluetoothStreamHandler?.sendEvent(isBluetoothEnabled(context))
            })

        gpsEventChannel.setStreamHandler(gpsStreamHandler)
        powerSaveModeEventChannel.setStreamHandler(powerSaveModeStreamHandler)
        bluetoothEventChannel.setStreamHandler(bluetoothStreamHandler)
    }

    private fun isPowerSaveModeEnabled(context: Context): Boolean? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val powerManager =
                context.getSystemService(POWER_SERVICE) as PowerManager
            powerManager.isPowerSaveMode
        } else {
            //To detect Power save mode state Android API level needs to be >= 21
            return null
        }
    }

    private fun isGpsEnabled(context: Context): Boolean {
        val locationManager = context.getSystemService(LOCATION_SERVICE) as LocationManager
        return locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
    }

    private fun isBluetoothEnabled(context: Context): Boolean? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            val bluetoothManager =
                context.getSystemService(BLUETOOTH_SERVICE) as BluetoothManager
            bluetoothManager.adapter.isEnabled
        } else {
            // To detect bluetooth state Android API level needs to be >= 18
            return null
        }
    }

    private fun teardownStreams() {
        gpsEventChannel.setStreamHandler(null)
        powerSaveModeEventChannel.setStreamHandler(null)
        bluetoothEventChannel.setStreamHandler(null)
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "bw_single_reading_settings")
        methodChannel.setMethodCallHandler(this)

        gpsEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "bw_streamed_settings/gps")
        powerSaveModeEventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "bw_streamed_settings/power_save_mode")
        bluetoothEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "bw_streamed_settings/bluetooth")

        _applicationContext = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        teardownStreams()
        _applicationContext = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "isGpsEnabled") {
            propagateError(result) {
                result.success(isGpsEnabled(_applicationContext!!))
            }
        } else if (call.method == "isPowerSaveModeEnabled") {
            propagateError(result) {
                result.success(isPowerSaveModeEnabled(_applicationContext!!))
            }
        } else if (call.method == "isBluetoothEnabled") {
            propagateError(result) {
                result.success(isBluetoothEnabled(_applicationContext!!))
            }
        } else {
            result.notImplemented()
        }
    }

    private fun <T> propagateError(result: Result, fn: () -> T) {
        try {
            fn()
        } catch (e: Exception) {
            result.error("CATCHED_ERROR", e.message, null)
        }
    }
}

class BoolStreamHandler(
    private val activity: Activity,
    private val eventsFiler: String,
    private val onSystemEvent: (context: Context) -> Unit
) :
    EventChannel.StreamHandler {

    var flutterSink: EventChannel.EventSink? = null

    private val broadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            onSystemEvent(context)
        }
    }

    override fun onListen(arguments: Any?, _sink: EventChannel.EventSink?) {
        flutterSink = _sink
        activity.registerReceiver(broadcastReceiver, IntentFilter(eventsFiler))
    }

    override fun onCancel(arguments: Any?) {
        activity.unregisterReceiver(broadcastReceiver)
    }

    fun sendEvent(value: Boolean?) {
        flutterSink?.success(value)
    }
}
