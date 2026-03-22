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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Troubleshooting survey card
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Troubleshooting Survey',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  //padding
                                  SizedBox(height: 4),

                                  Text(
                                    'Answer a few quick questions so we can understand your device\'s symptoms',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),

                                  //padding
                                  SizedBox(height: 8),
                                  
                                  Text(
                                    '3min',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.deepPurpleAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    //padding
                    const SizedBox(height: 40),

                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}