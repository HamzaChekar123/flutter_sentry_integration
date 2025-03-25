// Get device data based on platform
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

Future<Map<String, dynamic>> getDeviceData(DeviceInfoPlugin deviceInfo) async {
  if (kIsWeb) {
    final webInfo = await deviceInfo.webBrowserInfo;
    return {
      'browser': webInfo.browserName.toString(),
      'platform': webInfo.platform,
      'user_agent': webInfo.userAgent,
    };
  }

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return {
      'model': iosInfo.model,
      'os_version': iosInfo.systemVersion,
      'memory': iosInfo.utsname.machine,
    };
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    final androidInfo = await deviceInfo.androidInfo;
    return {
      'model': androidInfo.model,
      'os_version': androidInfo.version.release,
      'sdk_version': androidInfo.version.sdkInt.toString(),
      'manufacturer': androidInfo.manufacturer,
    };
  }

  return {'platform': defaultTargetPlatform.toString()};
}