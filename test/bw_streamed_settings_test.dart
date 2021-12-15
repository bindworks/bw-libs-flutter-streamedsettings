import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bw_streamed_settings/bw_streamed_settings.dart';

void main() {
  const MethodChannel channel = MethodChannel('bw_streamed_settings');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await BwStreamedSettings.platformVersion, '42');
  });
}
