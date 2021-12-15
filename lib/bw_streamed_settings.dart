import 'dart:async';

import 'package:flutter/services.dart';

class BwStreamedSettings {
  static const _streamedChannelName = 'bw_streamed_settings';
  static const _singleReadingChannel = MethodChannel('bw_single_reading_settings');

  static Future<String?> get platformVersion async {
    final String? version =
        await const MethodChannel('bw_streamed_settings').invokeMethod('getPlatformVersion');
    return version;
  }

  static final Stream<bool> _gpsEnabledStream = const EventChannel('$_streamedChannelName/gps')
      .receiveBroadcastStream()
      .map((event) => event as bool);
  static Stream<bool> get gpsEnabledStream async* {
    yield (await _singleReadingChannel.invokeMethod('isGpsEnabled') as bool);
    yield* _gpsEnabledStream;
  }

  static final Stream<bool> _powerSaveModeEnabledStream =
      const EventChannel('$_streamedChannelName/power_save_mode')
          .receiveBroadcastStream()
          .map((event) => event as bool);
  static Stream<bool> get powerSaveModeEnabledStream async* {
    yield (await _singleReadingChannel.invokeMethod('isPowerSaveModeEnabled') as bool);
    yield* _powerSaveModeEnabledStream;
  }

  static final Stream<bool> _bluetoothEnabledStream =
      const EventChannel('$_streamedChannelName/bluetooth')
          .receiveBroadcastStream()
          .map((event) => event as bool);
  static Stream<bool> get bluetoothEnabledStream async* {
    yield (await _singleReadingChannel.invokeMethod('isBluetoothEnabled') as bool);
    yield* _bluetoothEnabledStream;
  }
}
