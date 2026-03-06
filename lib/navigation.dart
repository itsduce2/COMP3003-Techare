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
  // Index of currently selected navigation tab
  int _selectedIndex = 0;

  // List of screens to display based on navigation selection
  final List<Widget> _screens = const [
    Dashboard(),
    DiagnosticsScreen(),
    RepairScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Main layout container with body and bottom navigation
    return Scaffold(
      // Display the selected screen based on current index
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // Bottom navigation bar for switching between screens
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        // Update selected index when a tab is tapped
        onTap: (index) => setState(() => _selectedIndex = index),
       
        // Colors for selected and unselected navigation items
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