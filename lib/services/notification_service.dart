import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // call once on app start to set up notifications
  static Future<void> initialise() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: initializationSettings, 
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap here
      },
    );
  }

  // request permission from the user (Android 13+)
  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static const String _prefKey = 'notifications_enabled';
  static const String _taskID = 'techare_background_check';
  static const String _taskName = 'techareCheck';

  // returns whether notifications are enabled (defaults true)
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? true;
  }

  // enables or disables background notifications and persists the choice
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
    if (enabled) {
      await Workmanager().registerPeriodicTask(
        _taskID,
        _taskName,
        frequency: const Duration(hours: 24),
      );
    } else {
      await Workmanager().cancelByUniqueName(_taskID);
    }
  }

  // shows a notification with a given id, title and body
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'techare_channel',
      'Techare Alerts',
      channelDescription: 'Predictive maintenance alerts from Techare',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
  }
}