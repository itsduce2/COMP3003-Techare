import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  // Device Profile state
  String _phoneAge = '';
  String _chargingHabit = '';

  @override
  void initState() {
    super.initState();
    // Load saved device profile values
    _loadDeviceProfile();
  }

  Future<void> _loadDeviceProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneAge = prefs.getString('phone_age') ?? '';
      _chargingHabit = prefs.getString('charging_habit') ?? '';
    });
  }

  // Dialog for Phone Age selection
  void _showPhoneAgeDialog() {
    // Parse existing saved value back into years/months
    int selectedYears = 0;
    int selectedMonths = 0;
    final match = RegExp(r'(\d+)y (\d+)m').firstMatch(_phoneAge);
    if (match != null) {
      selectedYears = int.parse(match.group(1)!);
      selectedMonths = int.parse(match.group(2)!);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Phone Age'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Years dropdown
                  Row(
                    children: [
                      const Text('Years:', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 16),
                      DropdownButton<int>(
                        value: selectedYears,
                        items: List.generate(11, (i) => i).map((y) {
                          return DropdownMenuItem(value: y, child: Text('$y'));
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedYears = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Months dropdown
                  Row(
                    children: [
                      const Text('Months:', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 16),
                      DropdownButton<int>(
                        value: selectedMonths,
                        items: List.generate(12, (i) => i).map((m) {
                          return DropdownMenuItem(value: m, child: Text('$m'));
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedMonths = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final saved = '${selectedYears}y ${selectedMonths}m';
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('phone_age', saved);
                    if (!mounted) return;
                    setState(() {
                      _phoneAge = saved;
                    });
                    nav.pop();
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.deepPurple)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog for Charging Habits selection
  void _showChargingHabitDialog() {
    // Parse existing saved value back into cycles
    double selectedCycles = 0;
    final existing = double.tryParse(_chargingHabit);
    if (existing != null) selectedCycles = existing;

    final controller = TextEditingController(
      text: selectedCycles > 0 ? selectedCycles.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Charging Habits'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'A full charge cycle = your battery going from 0% to 100% in total, even if topped up in smaller amounts throughout the day.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              // Cycles per day input
              Row(
                children: [
                  const Text('Cycles per day:', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: '0.0',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                final saved = controller.text.trim();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('charging_habit', saved);
                if (!mounted) return;
                setState(() {
                  _chargingHabit = saved;
                });
                nav.pop();
              },
              child: const Text('Save', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
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

            // Device Profile section
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
                      title: const Text('Phone Age', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        _phoneAge.isEmpty ? 'Not set' : _phoneAge,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: _showPhoneAgeDialog,
                    ),

                    const Divider(height: 1, color: Colors.black12),

                    ListTile(
                      title: const Text('Charging Habits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        _chargingHabit.isEmpty ? 'Not set' : _chargingHabit,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: _showChargingHabitDialog,
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
          
             //padding
              const SizedBox(height: 24),
              
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
                    title: const Text('Help', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                        // Placeholder
                    },
                  ),
                      
                  const Divider(height: 1, color: Colors.black12), 
                    ListTile(
                      title: const Text('Sign Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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