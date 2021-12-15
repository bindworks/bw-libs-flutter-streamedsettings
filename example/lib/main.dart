import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
  StreamSubscription<dynamic>? streamSubscriptionBluetooth;

  bool? gpsEnabled1;
  bool? gpsEnabled2;
  bool? powerSaveModeEnabled;
  bool? bluetoothEnabled;

  @override
  void initState() {
    super.initState();
  }

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
                  Expanded(child: Text('Gps enabled: $gpsEnabled1')),
                  TextButton(
                    onPressed: () {
                      streamSubscriptionGps = BwStreamedSettings.gpsEnabledStream.listen((event) {
                        setState(() {
                          gpsEnabled1 = event;
                        });
                      });
                    },
                    child: const Text('start listen'),
                  ),
                  TextButton(
                    onPressed: () {
                      streamSubscriptionGps?.cancel();
                    },
                    child: const Text('stop listen'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Gps enabled: $gpsEnabled2')),
                  TextButton(
                    onPressed: () {
                      BwStreamedSettings.gpsEnabledStream.listen((event) {
                        setState(() {
                          gpsEnabled2 = event;
                        });
                      });
                    },
                    child: const Text('start listen'),
                  ),
                  TextButton(
                    onPressed: () {
                      streamSubscriptionGps?.cancel();
                    },
                    child: const Text('stop listen'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Save mode enabled: $powerSaveModeEnabled')),
                  TextButton(
                    onPressed: () {
                      streamSubscriptionPowerSaveMode =
                          BwStreamedSettings.powerSaveModeEnabledStream.listen((event) {
                        setState(() {
                          powerSaveModeEnabled = event;
                        });
                      });
                    },
                    child: const Text('start listen'),
                  ),
                  TextButton(
                    onPressed: () {
                      streamSubscriptionPowerSaveMode?.cancel();
                    },
                    child: const Text('stop listen'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Bluetooth enabled: $bluetoothEnabled')),
                  TextButton(
                    onPressed: () {
                      streamSubscriptionBluetooth =
                          BwStreamedSettings.bluetoothEnabledStream.listen((event) {
                        setState(() {
                          bluetoothEnabled = event;
                        });
                      });
                    },
                    child: const Text('start listen'),
                  ),
                  TextButton(
                    onPressed: () {
                      streamSubscriptionBluetooth?.cancel();
                    },
                    child: const Text('stop listen'),
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
