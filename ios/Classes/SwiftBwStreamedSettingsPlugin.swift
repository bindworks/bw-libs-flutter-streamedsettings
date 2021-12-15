import Flutter
import UIKit

public class SwiftBwStreamedSettingsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "bw_streamed_settings", binaryMessenger: registrar.messenger())
    let instance = SwiftBwStreamedSettingsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
