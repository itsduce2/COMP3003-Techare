// UI tests for this app require a real device or emulator due to platform
// channel dependencies (WorkManager, local notifications, battery info).
// Unit tests for services and data models are in:
//   test/services/login_service_test.dart
//   test/services/battery_prediction_service_test.dart
//   test/services/notifications_manager_test.dart
//   test/data/tutorials_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('basic MaterialApp builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Techare'))),
    );
    expect(find.text('Techare'), findsOneWidget);
  });
}
