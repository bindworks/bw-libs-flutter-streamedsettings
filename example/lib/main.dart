import 'package:flutter/material.dart';
import 'dart:async';

import 'package:bw_streamed_settings/bw_streamed_settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<dynamic>? streamSubscriptionGps;
  StreamSubscription<dynamic>? streamSubscriptionPowerSaveMode;
  StreamSubscription<dynamic>? streamSubscriptionBluetooth1;
  StreamSubscription<dynamic>? streamSubscriptionBluetooth2;

  bool? gpsEnabled;
  bool? powerSaveModeEnabled;
  bool? bluetoothEnabled1;
  bool? bluetoothEnabled2;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BW streamed settings'),
        ),
        body: Center(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text('Gps enabled: $gpsEnabled')),
                  TextButton(
                    onPressed: () async {
                      if (streamSubscriptionGps == null) {
                        streamSubscriptionGps = streamSubscriptionGps =
                            BwStreamedSettings.gpsEnabledStream.listen((event) {
                          setState(() {
                            gpsEnabled = event;
                          });
                        });
                      } else {
                        await streamSubscriptionGps?.cancel();
                        setState(() {
                          streamSubscriptionGps = null;
                        });
                      }
                    },
                    child: Text((streamSubscriptionGps == null) ? 'start listen' : 'stop listen'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Save mode enabled: $powerSaveModeEnabled')),
                  TextButton(
                    onPressed: () async {
                      if (streamSubscriptionPowerSaveMode == null) {
                        streamSubscriptionPowerSaveMode =
                            BwStreamedSettings.powerSaveModeEnabledStream.listen((event) {
                          setState(() {
                            powerSaveModeEnabled = event;
                          });
                        });
                      } else {
                        await streamSubscriptionPowerSaveMode?.cancel();
                        setState(() {
                          streamSubscriptionPowerSaveMode = null;
                        });
                      }
                    },
                    child: Text(
                        (streamSubscriptionPowerSaveMode == null) ? 'start listen' : 'stop listen'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text('Test 2 simultaneus Bluetooth on/off streams'),
              Row(
                children: [
                  Expanded(child: Text('#1 Bluetooth enabled: $bluetoothEnabled1')),
                  TextButton(
                    onPressed: () async {
                      if (streamSubscriptionBluetooth1 == null) {
                        streamSubscriptionBluetooth1 =
                            BwStreamedSettings.bluetoothEnabledStream.listen((event) {
                          setState(() {
                            bluetoothEnabled1 = event;
                          });
                        });
                      } else {
                        await streamSubscriptionBluetooth1?.cancel();
                        setState(() {
                          streamSubscriptionBluetooth1 = null;
                        });
                      }
                    },
                    child: Text(
                        (streamSubscriptionBluetooth1 == null) ? 'start listen' : 'stop listen'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('#2 Bluetooth enabled: $bluetoothEnabled2')),
                  TextButton(
                    onPressed: () async {
                      if (streamSubscriptionBluetooth2 == null) {
                        streamSubscriptionBluetooth2 =
                            BwStreamedSettings.bluetoothEnabledStream.listen((event) {
                          setState(() {
                            bluetoothEnabled2 = event;
                          });
                        });
                      } else {
                        await streamSubscriptionBluetooth2?.cancel();
                        setState(() {
                          streamSubscriptionBluetooth2 = null;
                        });
                      }
                    },
                    child: Text(
                        (streamSubscriptionBluetooth2 == null) ? 'start listen' : 'stop listen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
