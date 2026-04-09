import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'navigation.dart';
import 'notification_service.dart';
import 'notifications.dart';

// called by WorkManager in the background
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationService.initialise();
    await Notifications.run();
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialise notifications
  await NotificationService.initialise();
  await NotificationService.requestPermission();

  // initialise WorkManager and register 24 hour background task
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'techare_background_check',
    'techareCheck',
    frequency: const Duration(hours: 24),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Techare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //ColorScheme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //Screens
      home: const BottomNavigation(),
    );
  }
}