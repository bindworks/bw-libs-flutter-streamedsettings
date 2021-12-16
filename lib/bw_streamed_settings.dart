import 'dart:async';

import 'package:flutter/services.dart';

class BwStreamedSettings {
  static const _gpsEventChannel = EventChannel('bw_streamed_settings/gps');
  static const _powerSaveModeEventChannel = EventChannel('bw_streamed_settings/power_save_mode');
  static const _bluetoothEventChannel = EventChannel('bw_streamed_settings/bluetooth');
  static const _methodChannel = MethodChannel('bw_single_reading_settings');

  static final Stream<bool?> _gpsEnabledStream =
      _gpsEventChannel.receiveBroadcastStream().map((event) => event as bool?);
  static Stream<bool?> get gpsEnabledStream async* {
    yield (await _methodChannel.invokeMethod('isGpsEnabled') as bool?);
    yield* _gpsEnabledStream;
  }

  static final Stream<bool?> _powerSaveModeEnabledStream =
      _powerSaveModeEventChannel.receiveBroadcastStream().map((event) => event as bool?);
  static Stream<bool?> get powerSaveModeEnabledStream async* {
    yield (await _methodChannel.invokeMethod('isPowerSaveModeEnabled') as bool?);
    yield* _powerSaveModeEnabledStream;
  }

  static final Stream<bool?> _bluetoothEnabledStream =
      _bluetoothEventChannel.receiveBroadcastStream().map((event) => event as bool?);
  static Stream<bool?> get bluetoothEnabledStream async* {
    yield (await _methodChannel.invokeMethod('isBluetoothEnabled') as bool?);
    yield* _bluetoothEnabledStream;
  }
}
