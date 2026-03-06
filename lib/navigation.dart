import 'package:flutter/material.dart';
import 'package:techare_application_comp3003/screens/dashboard.dart';
import 'package:techare_application_comp3003/screens/diagnostics.dart';
import 'package:techare_application_comp3003/screens/repair.dart';
import 'package:techare_application_comp3003/screens/settings.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  // Index of currently selected
  int _selectedIndex = 0;

  // List of screens 
  final List<Widget> _screens = const [
    Dashboard(),
    DiagnosticsScreen(),
    RepairScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
       
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        
        // Nav icons and labels
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.health_and_safety), label: 'Diagnostics'),
          BottomNavigationBarItem(icon: Icon(Icons.handyman_rounded), label: 'Repair'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}