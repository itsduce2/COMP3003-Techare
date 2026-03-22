import 'package:flutter/material.dart';
import '../device_info_service.dart';

class RepairScreen extends StatefulWidget {
  const RepairScreen({super.key});

  @override
  State<RepairScreen> createState() => _RepairScreenState();
}

class _RepairScreenState extends State<RepairScreen> {

  // Device info variables
  String _deviceName = 'Your Device';

  @override
  void initState() {
    super.initState();
    _loadDeviceName();
  }

  // calls the service to get device name
  Future<void> _loadDeviceName() async {
    final data = await DeviceInfoService.getDeviceDetails();
    setState(() {
      _deviceName = data['name'] ?? 'Your Device';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // background colour
      backgroundColor: Colors.blueGrey[50],

      body: SafeArea(
        //SafeArea
        child: SingleChildScrollView(
          child: Column(
            // vertical column layout
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // Greeting column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hi, Amina 👋',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Repair your device',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),

                    // Icons
                    Row(
                      children: const [
                        Icon(Icons.notifications_none, size: 28),
                        SizedBox(width: 16),
                        Icon(Icons.account_circle, size: 40),
                      ],
                    ),

                  ],
                ),
              ),

              //padding
              const SizedBox(height: 24),

            ],
          ),
        ),
      ),
    );
  }
}