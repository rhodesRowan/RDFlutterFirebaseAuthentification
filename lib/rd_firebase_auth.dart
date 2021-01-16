
import 'dart:async';

import 'package:flutter/services.dart';

class RdFirebaseAuth {
  static const MethodChannel _channel =
      const MethodChannel('rd_firebase_auth');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
