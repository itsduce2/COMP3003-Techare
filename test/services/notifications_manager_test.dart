// Tests for Notifications.run() that avoid triggering actual platform
// notification calls. Each test either hits an early-return path or uses
// the "already notified" flag so showNotification() is never reached.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techare_application_comp3003/services/notifications_manager.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ── Empty prefs ──────────────────────────────────────────────────────────────

  group('run() - empty SharedPreferences', () {
    test('completes without error when no data is stored', () async {
      await expectLater(Notifications.run(), completes);
    });
  });

  // ── Storage alerts ───────────────────────────────────────────────────────────

  group('run() - storage alerts', () {
    test('resets both notification flags when storage is below 85%', () async {
      SharedPreferences.setMockInitialValues({
        'last_storage_percent': '80',
        'notified_storage_critical': true,
        'notified_storage_warning': true,
      });
      await Notifications.run();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notified_storage_critical'), isFalse);
      expect(prefs.getBool('notified_storage_warning'), isFalse);
    });

    test('does not re-notify when critical flag is already set at 98%', () async {
      SharedPreferences.setMockInitialValues({
        'last_storage_percent': '98',
        'notified_storage_critical': true,
        'notified_storage_warning': true,
      });
      await Notifications.run();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notified_storage_critical'), isTrue);
    });

    test('resets warning flag when storage is at or above 95%', () async {
      SharedPreferences.setMockInitialValues({
        'last_storage_percent': '98',
        'notified_storage_critical': true,
        'notified_storage_warning': true,
      });
      await Notifications.run();
      final prefs = await SharedPreferences.getInstance();
      // storage ≥ 95 → warning condition is false → else branch resets it
      expect(prefs.getBool('notified_storage_warning'), isFalse);
    });

    test('does not re-notify warning when flag already set and storage is 85–95%', () async {
      SharedPreferences.setMockInitialValues({
        'last_storage_percent': '90',
        'notified_storage_critical': true,
        'notified_storage_warning': true,
      });
      await Notifications.run();
      final prefs = await SharedPreferences.getInstance();
      // 90 < 95 → critical else branch resets it
      expect(prefs.getBool('notified_storage_critical'), isFalse);
      // 85 ≤ 90 < 95 → warning branch, alreadyNotified=true → flag unchanged
      expect(prefs.getBool('notified_storage_warning'), isTrue);
    });

    test('skips storage check entirely when last_storage_percent is not set', () async {
      await Notifications.run();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notified_storage_critical'), isNull);
      expect(prefs.getBool('notified_storage_warning'), isNull);
    });
  });

  // ── Battery temperature alerts ───────────────────────────────────────────────

  group('run() - battery temperature alerts', () {
    test('resets temperature flag when temp is below 36°C', () async {
      SharedPreferences.setMockInitialValues({
        'last_battery_temperature': '30°C',
        'notified_battery_temp': true,
      });
      await Notifications.run();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notified_battery_temp'), isFalse);
    });

    test('does not re-notify when high-temp flag is already set', () async {
      SharedPreferences.setMockInitialValues({
        'last_battery_temperature': '40°C',
        'notified_battery_temp': true,
      });
      await Notifications.run();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notified_battery_temp'), isTrue);
    });

    test('skips temperature check when value is not set', () async {
      await expectLater(Notifications.run(), completes);
    });
  });

  // ── Battery health change alerts ─────────────────────────────────────────────

  group('run() - battery health change', () {
    test('does not fire when saved and current health are the same', () async {
      SharedPreferences.setMockInitialValues({
        'saved_battery_health': 'Good',
        'last_battery_health': 'Good',
      });
      await Notifications.run();
      final prefs = await SharedPreferences.getInstance();
      // saved_battery_health is only updated when health changes
      expect(prefs.getString('saved_battery_health'), 'Good');
    });

    test('skips health check when saved health is empty', () async {
      SharedPreferences.setMockInitialValues({
        'saved_battery_health': '',
        'last_battery_health': 'Good',
      });
      await expectLater(Notifications.run(), completes);
    });

    test('skips health check when both health values are absent', () async {
      await expectLater(Notifications.run(), completes);
    });
  });

  // ── Scan reminder alerts ─────────────────────────────────────────────────────

  group('run() - scan reminder', () {
    test('resets reminder flag when last scan was today (< 30 days)', () async {
      final today = DateTime.now();
      final scanStr = '${today.day}/${today.month}/${today.year}';
      SharedPreferences.setMockInitialValues({
        'last_scan_date': scanStr,
        'notified_scan_reminder': true,
      });
      await Notifications.run();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notified_scan_reminder'), isFalse);
    });

    test('does not re-notify when old scan flag is already set', () async {
      final oldDate = DateTime.now().subtract(const Duration(days: 60));
      final scanStr = '${oldDate.day}/${oldDate.month}/${oldDate.year}';
      SharedPreferences.setMockInitialValues({
        'last_scan_date': scanStr,
        'notified_scan_reminder': true,
      });
      await Notifications.run();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notified_scan_reminder'), isTrue);
    });

    test('skips check when last_scan_date is not set', () async {
      await expectLater(Notifications.run(), completes);
    });

    test('skips check when last_scan_date is the Never placeholder', () async {
      SharedPreferences.setMockInitialValues({'last_scan_date': 'Never'});
      await expectLater(Notifications.run(), completes);
    });

    test('skips check when last_scan_date has an unexpected format', () async {
      SharedPreferences.setMockInitialValues({'last_scan_date': 'not-a-date'});
      await expectLater(Notifications.run(), completes);
    });
  });
}
