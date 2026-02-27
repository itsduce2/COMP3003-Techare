import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background color.
      backgroundColor: Colors.blueGrey[50],
      
      body: SafeArea(
        //SafeArea
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Pixel 7',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Android 14',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
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

                  const SizedBox(height: 16), // Spacing before metrics

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
                                color: Colors.grey.withOpacity(0.25),
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
                                color: Colors.grey.withOpacity(0.25),
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
                                color: Colors.grey.withOpacity(0.25),
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

                  const SizedBox(height: 32), // Space before button

                  // Run diagnostic button
                  SizedBox(
                    width: double.infinity, // full width
                    height: 56, // button height
                    child: ElevatedButton(
                      onPressed: () {
                        // diagnostic action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent, // bright purple
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
                  
                  const SizedBox(height: 24), // Space at the very bottom

                ],
              ),
            ),

            


          ],
          
        ),
      ),
    ); 
  }
}
  