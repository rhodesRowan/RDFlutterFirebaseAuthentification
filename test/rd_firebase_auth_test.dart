import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rd_firebase_auth/rd_firebase_auth.dart';

void main() {
  const MethodChannel channel = MethodChannel('rd_firebase_auth');

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
    expect(await RdFirebaseAuth.platformVersion, '42');
  });
}
