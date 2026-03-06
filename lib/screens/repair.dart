import 'package:flutter/material.dart';

class RepairScreen extends StatelessWidget {
  const RepairScreen({Key? key}) : super(key: key);

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