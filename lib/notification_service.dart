import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // call once on app start to set up notifications
  static Future<void> initialise() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    // FIX: Added 'settings:' name here
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

    // Added parameter names (id:, title:, body:, notificationDetails:)
    // await to ensure notification is shown before method returns
    await _plugin.show(
      id: id, 
      title: title, 
      body: body, 
      notificationDetails: details,
    );
  }
}