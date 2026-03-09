import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  static Future<Map<String, String>> getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    // check if device is Android or iOS & return info
    try {
      //Android
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return {
          'name': androidInfo.model,
          'os': androidInfo.version.release
        };
      } 
      
      //iOS
      else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return {
          'name': iosInfo.name,
          'os': iosInfo.systemVersion
        };
      }
    } 
    
    //unknown device or device info error
    catch (e) {
      return {'name': 'Unknown Device', 'os': 'Unknown OS'};
    }
    
    return {'name': 'Unknown Device', 'os': 'Unknown OS'};
  }
}