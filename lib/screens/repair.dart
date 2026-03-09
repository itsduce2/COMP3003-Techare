import 'package:flutter/material.dart';

class RepairScreen extends StatelessWidget {
  const RepairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair'),
      ),
      body: const Center(
        child: Text('Repair Screen'),
      ),
    );
  }
}