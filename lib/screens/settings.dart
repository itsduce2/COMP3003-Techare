import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
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
                        'Here are your settings',
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

              // Account & Privacy section
            Padding(
                
              padding: const EdgeInsets.symmetric(horizontal: 24.0),

              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.grey.shade300), 
                ),
              
                child: Column(
                  children:[
                    ListTile(
                      title: Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      subtitle: Text('Name, Email, Password', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        // placeholder
                      },
                      
                    ),

                    Divider(height: 1, color: Colors.black12),

                    ListTile(
                      title: Text('Privacy Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      subtitle: Text('Data and tracking', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        // placeholder
                      },
                    ),
                  ],
                ),
                
              

              ),
            ),

              //padding
              const SizedBox(height: 24),

              // Notifications section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300), 
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Push Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                        activeThumbColor: Colors.deepPurple,
                      ),
                      onTap: () {
                        setState(() {
                          _notificationsEnabled = !_notificationsEnabled;
                        });
                      },
                    ),
                    const Divider(height: 1, color: Colors.black12), 
                    ListTile(
                      title: const Text('Manage Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      subtitle: const Text('Default Settings', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        // Placeholder
                      },
                    ),
                    
                  ],
                ),
              ),
            ),  
          ],
        ),
      ),
    ),
  );
  }
}