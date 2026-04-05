import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'battery_prediction_service.dart';

class Notifications {

  // notification ids - each alert type has a unique id
  static const int _storageWarningId = 1;
  static const int _storageCriticalId = 2;
  static const int _battery6MonthsId = 3;
  static const int _battery3MonthsId = 4;
  static const int _battery1MonthId = 5;
  static const int _scanReminderId = 6;

  // main method called by WorkManager in the background
  static Future<void> run() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkStorageAlerts(prefs);
    await _checkBatteryPredictionAlerts(prefs);
    await _checkScanReminder(prefs);
  }

  // checks storage and fires alerts at 85% and 95%
  static Future<void> _checkStorageAlerts(SharedPreferences prefs) async {
    final storageStr = prefs.getString('last_storage_percent') ?? '';
    final storage = double.tryParse(storageStr);
    if (storage == null) return;

    // critical storage alert
    if (storage >= 95) {
      final alreadyNotified = prefs.getBool('notified_storage_critical') ?? false;
      if (!alreadyNotified) {
        await NotificationService.showNotification(
          id: _storageCriticalId,
          title: 'Storage Critically Full',
          body: 'Your storage is at ${storage.toStringAsFixed(0)}%. Free up space to keep your device running well.',
        );
        await prefs.setBool('notified_storage_critical', true);
      }
    } else {
      // reset flag once storage drops below 95%
      await prefs.setBool('notified_storage_critical', false);
    }

    // storage warning alert
    if (storage >= 85 && storage < 95) {
      final alreadyNotified = prefs.getBool('notified_storage_warning') ?? false;
      if (!alreadyNotified) {
        await NotificationService.showNotification(
          id: _storageWarningId,
          title: 'Storage Getting Full',
          body: 'Your storage is at ${storage.toStringAsFixed(0)}%. Consider clearing files soon.',
        );
        await prefs.setBool('notified_storage_warning', true);
      }
    } else {
      // reset flag once storage drops below 85%
      await prefs.setBool('notified_storage_warning', false);
    }
  }

  // checks battery prediction and fires alerts at 6, 3 and 1 month thresholds
  static Future<void> _checkBatteryPredictionAlerts(SharedPreferences prefs) async {
    final result = await BatteryPredictionService.predict();
    if (!result.canPredict) return;

    // 6 month alert
    if (result.predicted6Months < 80) {
      final alreadyNotified = prefs.getBool('notified_battery_6_months') ?? false;
      if (!alreadyNotified) {
        await NotificationService.showNotification(
          id: _battery6MonthsId,
          title: 'Battery Health Alert',
          body: 'Your battery is predicted to drop below 80% within 6 months. Consider planning a replacement.',
        );
        await prefs.setBool('notified_battery_6_months', true);
      }
    }

    // 3 month alert
    if (result.predicted3Months < 80) {
      final alreadyNotified = prefs.getBool('notified_battery_3_months') ?? false;
      if (!alreadyNotified) {
        await NotificationService.showNotification(
          id: _battery3MonthsId,
          title: 'Battery Replacement Recommended',
          body: 'Your battery may need replacing within 3 months. Plan ahead to avoid disruption.',
        );
        await prefs.setBool('notified_battery_3_months', true);
      }
    }

    // 1 month alert
    if (result.predicted1Month < 80) {
      final alreadyNotified = prefs.getBool('notified_battery_1_month') ?? false;
      if (!alreadyNotified) {
        await NotificationService.showNotification(
          id: _battery1MonthId,
          title: 'Battery Replacement Needed Soon',
          body: 'Your battery health is expected to drop below 80% within the next month. Consider replacing it soon.',
        );
        await prefs.setBool('notified_battery_1_month', true);
      }
    }
  }

  // reminds the user to scan if they havent done so in 30 days
  static Future<void> _checkScanReminder(SharedPreferences prefs) async {
    final lastScanStr = prefs.getString('last_scan_date') ?? '';
    if (lastScanStr.isEmpty || lastScanStr == 'Never') return;

    // parse last scan date from 'day/month/year' format
    final parts = lastScanStr.split('/');
    if (parts.length != 3) return;

    final lastScan = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );

    final daysSinceLastScan = DateTime.now().difference(lastScan).inDays;

    if (daysSinceLastScan >= 30) {
      final alreadyNotified = prefs.getBool('notified_scan_reminder') ?? false;
      if (!alreadyNotified) {
        await NotificationService.showNotification(
          id: _scanReminderId,
          title: 'Time for a Diagnostic',
          body: 'It has been $daysSinceLastScan days since your last scan. Run a diagnostic to keep your predictions accurate.',
        );
        await prefs.setBool('notified_scan_reminder', true);
      }
    } else {
      // reset reminder once they scan again
      await prefs.setBool('notified_scan_reminder', false);
    }
  }
}