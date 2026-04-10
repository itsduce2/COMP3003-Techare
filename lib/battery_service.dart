import 'dart:io';
import 'package:battery_info_v2/battery_info_plugin.dart';

class BatteryService {

  static Future<Map<String, dynamic>> getBatteryInfo() async {
    try {
      if (Platform.isAndroid) {

        final batteryInfo = await BatteryInfoPlugin().androidBatteryInfo;

        if (batteryInfo != null) {

          String batteryHealth = batteryInfo.health ?? 'unknown';
          String health = batteryHealth
          .replaceAll('health', '')
          .replaceAll('_', '');

          return {
            'level': batteryInfo.batteryLevel ?? 0,
            'health': health, 
            'temperature': '${batteryInfo.temperature ?? 0}°C', 
          };
        }
      } 
      
      return {
        'level': 0,
        'health': Platform.isIOS ? 'N/A (iOS)' : 'UNKNOWN',
        'temperature': 'N/A',
      };
      
    } catch (e) {
      return { 'level': 0, 'health': 'ERROR', 'temperature': 'ERROR' };
    }
  }
}