import 'package:flutter/material.dart';
import '../device_info_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  String _deviceName = 'Loading device info...';
  String _deviceOS = 'Loading OS info...';

  //calls service to get device info 
  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  // loads device data and updates state
  Future<void> _loadDeviceData() async {
    final data = await DeviceInfoService.getDeviceDetails();
    setState(() {
      _deviceName = data['name'] ?? 'Unknown';
      _deviceOS = data['os'] ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      // background color.
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
              padding: const EdgeInsets.all(24.0), // Padding
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
                        'Welcome to Techare',
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
         
            const SizedBox(height: 24),

            // Device Health & info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  
                  // Device info
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
             
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.withOpacity(0.25),
                      //     blurRadius: 10,
                      //     offset: const Offset(0, 4),
                      //   ),
                      // ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.smartphone, size: 40, color: Colors.grey),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _deviceName,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _deviceOS,
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  //padding
                  const SizedBox(height: 16),


                  // Health status
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 40, color: Colors.orange),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Fair',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Overall good health',
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // padding
                  const SizedBox(height: 16),

                  // Metrics section
                  Row(
                    children: [
                      
                      // Battery
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: const [
                              Text('Battery', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              SizedBox(height: 12),
                              Icon(Icons.battery_charging_full, size: 32, color: Colors.orange),
                              SizedBox(height: 12),
                              Text('Health:', style: TextStyle(fontSize: 12)),
                              Text('70% [degraded]', style: TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),

                      // Padding
                      const SizedBox(width: 12),

                      // Storage 
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),


                          child: Column(
                            children: const [
                              Text('Storage', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              SizedBox(height: 12),
                              Icon(Icons.pie_chart, size: 32, color: Colors.deepPurple),
                              SizedBox(height: 12),
                              Text('88% Used', style: TextStyle(fontSize: 14)),
                              Text('Warning: Low space', style: TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
                      
                              
                            ],
                          ),
                        ),
                      ),

                      // padding
                      const SizedBox(width: 12), 

                      // Temperature 
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: const [
                              Text('Temperature', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              SizedBox(height: 12),
                              Icon(Icons.thermostat, size: 32, color: Colors.black87),
                              SizedBox(height: 12),
                              Text('Normal:', style: TextStyle(fontSize: 12)),
                              Text('32°C', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),

                  // padding
                  const SizedBox(height: 32), 

                  // Run diagnostic button
                  SizedBox(
                    width: double.infinity, // .infinity for full width
                    height: 56, 
                    child: ElevatedButton(
                      onPressed: () {
                        //placeholder for diagnostic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Run Diagnostic',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  //padding
                  const SizedBox(height: 24), 

                  // Recent diagnostic card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Recent Diagnostic', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('(Last Scan xx/xx/xx)', style: TextStyle(fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            // not implemented yet
                          },
                          child: const Text('View Results', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  
                  //padding
                  const SizedBox(height: 16), 

                  // Top row of 4x4 grid
                  Row(
                    children: [
                      // Maintenance alerts 
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: const [
                              Icon(Icons.notifications_active_outlined, color: Colors.deepPurple, size: 28),
                              SizedBox(width: 12),
                              Expanded(child: Text('Maintenance\nAlerts', style: TextStyle(fontSize: 14))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Repair tutorials 
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: const [
                              Icon(Icons.menu_book, color: Colors.deepPurple, size: 28),
                              SizedBox(width: 12),
                              Expanded(child: Text('Repair\nTutorials', style: TextStyle(fontSize: 14))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12), // gap between grid rows
                  
                  // Bottom row (4x4 grid)
                  Row(
                    children: [
                      // Resources 
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: const [
                              Icon(Icons.inventory_2_outlined, color: Colors.deepPurple, size: 28),
                              SizedBox(width: 12),
                              Expanded(child: Text('Resources\n', style: TextStyle(fontSize: 14))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Privacy & data
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: const [
                              Icon(Icons.shield_outlined, color: Colors.deepPurple, size: 28),
                              SizedBox(width: 12),
                              Expanded(child: Text('Privacy\n& Data', style: TextStyle(fontSize: 14))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  //padding
                  const SizedBox(height: 16), 

                  // Tips
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Tips for your device', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Storage is high; consider clearing large files', style: TextStyle(fontSize: 14, color: Colors.black87)),
                      ],
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
  