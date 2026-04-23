import 'package:flutter/material.dart';
import 'package:techare_application_comp3003/screens/login.dart';
import 'package:workmanager/workmanager.dart';
import 'services/notification_service.dart';
import 'services/notifications_manager.dart';
import 'services/login_service.dart';

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

  //demo account
  await LoginService.setDemoAccount();

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
      home: const LoginScreen(),
    );
  }
}