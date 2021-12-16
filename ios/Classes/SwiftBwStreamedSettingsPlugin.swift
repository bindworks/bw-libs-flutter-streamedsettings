import Flutter
import UIKit
import CoreLocation
import CoreBluetooth

public class SwiftBwStreamedSettingsPlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate, CLLocationManagerDelegate {
    
    var bluetoothManager: CBCentralManager? = nil
    var locationManager: CLLocationManager? = nil
    
    let gpsStreamHandler = BoolEventsStreamHandler()
    let powerSaveModeStreamHandler = BoolEventsStreamHandler()
    let bluetoothStreamHandler = BoolEventsStreamHandler()
    
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothStreamHandler.sendEvent(isBluetoothEnabled())
    }
    
    @objc  func lowPowerDidUpdateState(notification: Notification) {
        powerSaveModeStreamHandler.sendEvent(isPowerSaveModeEnabled())
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        gpsStreamHandler.sendEvent(isGpsEnabled())
    }
    
    
    public func isGpsEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
        
    public func isPowerSaveModeEnabled() -> Bool {
        return ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    public func isBluetoothEnabled() -> Bool? {
        if(bluetoothManager == nil){
            return nil
        }else{
            return bluetoothManager!.state == .poweredOn
        }
    }
     
    
    @objc public func applicationDidBecomeActive(){
        // If user turn on Bluetooth, gps, etc. in device settings, and move back to the app, we want to be notified by this change
        gpsStreamHandler.sendEvent(isGpsEnabled())
        powerSaveModeStreamHandler.sendEvent(isPowerSaveModeEnabled())
        bluetoothStreamHandler.sendEvent(isBluetoothEnabled())
    }
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "bw_single_reading_settings", binaryMessenger: registrar.messenger())
        let gpsEventChannel = FlutterEventChannel(name: "bw_streamed_settings/gps", binaryMessenger: registrar.messenger())
        let powerSaveModeEventChannel = FlutterEventChannel(name: "bw_streamed_settings/power_save_mode", binaryMessenger: registrar.messenger())
        let bluetoothEventChannel = FlutterEventChannel(name: "bw_streamed_settings/bluetooth", binaryMessenger: registrar.messenger())
        
        let instance = SwiftBwStreamedSettingsPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        
        let infoPlistBluetoothAlwaysUsageDescription = Bundle.main.object(forInfoDictionaryKey: "NSBluetoothAlwaysUsageDescription") as? String
        if(infoPlistBluetoothAlwaysUsageDescription != nil){
            // to use bluetooth you need to have this in info.plist
            bluetoothEventChannel.setStreamHandler(instance.bluetoothStreamHandler)
            instance.bluetoothManager = CBCentralManager()
            instance.bluetoothManager?.delegate = instance
        }
                
        gpsEventChannel.setStreamHandler(instance.gpsStreamHandler)
        powerSaveModeEventChannel.setStreamHandler(instance.powerSaveModeStreamHandler)

        NotificationCenter.default.addObserver(instance, selector: #selector(instance.lowPowerDidUpdateState), name: Notification.Name.NSProcessInfoPowerStateDidChange, object: nil)

        instance.locationManager = CLLocationManager()
        instance.locationManager?.delegate = instance


        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(instance, selector: #selector(instance.applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method.elementsEqual("isGpsEnabled")){
            result(isGpsEnabled())
        } else if (call.method.elementsEqual("isPowerSaveModeEnabled")){
            result(isPowerSaveModeEnabled())
        } else if (call.method.elementsEqual("isBluetoothEnabled")){
            result(isBluetoothEnabled())
        }else{
            result(nil)
        }
    }
    
    class BoolEventsStreamHandler: NSObject, FlutterStreamHandler {
        private var _eventSink: FlutterEventSink?
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            _eventSink = events
            return nil
        }
        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            _eventSink = nil
            return nil
        }
        func sendEvent(_ value: Bool?) {
            _eventSink?(value)
        }
    }
}
