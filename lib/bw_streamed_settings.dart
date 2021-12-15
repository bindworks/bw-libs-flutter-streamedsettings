
import 'dart:async';

import 'package:flutter/services.dart';

class BwStreamedSettings {
  static const MethodChannel _channel = MethodChannel('bw_streamed_settings');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
