import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Test')),
      body: Center(
        child: Image.asset('assets/android/step1.jpg'),
      ),
    );
  }
}