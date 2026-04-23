import 'package:flutter/material.dart';
import '../widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techare_application_comp3003/screens/login.dart';
import 'onboarding.dart';
import '../services/login_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  // Device Profile state
  String _phoneAge = '';
  String _cycles = '';
  String _phoneBrand = '';
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    // Load saved device profile values
    _loadDeviceProfile();
  }

  Future<void> _loadDeviceProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final agePref = await LoginService.key('phone_age');
    final setDatePref = await LoginService.key('phone_age_set_date');
    final cycles = await LoginService.key('charging_habit');
    final phoneBrand = await LoginService.key('phone_brand');
    final name = await LoginService.currentUserName();
    final email = await LoginService.currentUser() ?? '';
    final notificationsEnabled = await NotificationService.isEnabled();

    final age = prefs.getString(agePref)     ?? '';
    final setDate = prefs.getString(setDatePref);

    setState(() {
      _phoneAge = _addMonths(age, setDate);
      _cycles = prefs.getString(cycles) ?? '';
      _phoneBrand = prefs.getString(phoneBrand)  ?? '';
      _userName = name;
      _userEmail = email;
      _notificationsEnabled = notificationsEnabled;
    });
  }

  // Add calendar months elapsed since the age was last set
  String _addMonths(String age, String? setDate) {
    //nothing saved yet, return as is
    if (age.isEmpty || setDate == null) return age;

    //pull years and months out of the saved string e.g. "2y 3m"
    final match = RegExp(r'(\d+)y (\d+)m').firstMatch(age);
    if (match == null) return age;

    int years  = int.parse(match.group(1)!);
    int months = int.parse(match.group(2)!);

    //parse the date the age was last set
    final from = DateTime.tryParse(setDate);
    if (from == null) return age;

    //work out how many calendar months have passed since then
    final now = DateTime.now();
    months += (now.year - from.year) * 12 + (now.month - from.month);
    
    //carry overflow months into years
    if (months >= 12) {
      years  += months ~/ 12;
      months  = months % 12;
    }

    return '${years}y ${months}m';
  }

  Future<void> _toggleNotifications(bool value) async {
    await NotificationService.setEnabled(value);
    if (!mounted) return;
    setState(() => _notificationsEnabled = value);
  }

  // Account dialog - edit name and password
  void _showAccountDialog() {
    final nameController = TextEditingController(text: _userName);
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Name', style: TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Email', style: TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: TextEditingController(text: _userEmail),
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                const Text('Current Password', style: TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: currentPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('New Password', style: TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final nav   = Navigator.of(context);
                final prefs = await SharedPreferences.getInstance();

                // save updated name
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != _userName) {
                  final nameKey = LoginService.keyFor(_userEmail, 'name');
                  await prefs.setString(nameKey, newName);
                }

                // update password if fields filled
                final currentPass = currentPassController.text;
                final newPass = newPassController.text.trim();
                if (currentPass.isNotEmpty || newPass.isNotEmpty) {
                  final userPassword = LoginService.keyFor(_userEmail, 'password');
                  final storedPass = prefs.getString(userPassword) ?? '';
                  if (currentPass != storedPass) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(nav.context).showSnackBar(
                      const SnackBar(content: Text('Current password is incorrect.')),
                    );
                    return;
                  }
                  if (newPass.isEmpty) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(nav.context).showSnackBar(
                      const SnackBar(content: Text('New password cannot be empty.')),
                    );
                    return;
                  }
                  await prefs.setString(userPassword, newPass);
                }

                if (!mounted) return;
                setState(() {
                  if (newName.isNotEmpty) _userName = newName;
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

  // Dialog for Phone Age selection
  void _showPhoneAgeDialog() {
    // Parse current display value back into years/months for the dropdowns
    int selYears = 0;
    int selMonths = 0;
    final match = RegExp(r'(\d+)y (\d+)m').firstMatch(_phoneAge);
    if (match != null) {
      selYears = int.parse(match.group(1)!);
      selMonths = int.parse(match.group(2)!);
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
                        value: selYears,
                        items: List.generate(11, (i) => i).map((y) {
                          return DropdownMenuItem(value: y, child: Text('$y'));
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selYears = value!;
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
                        value: selMonths,
                        items: List.generate(12, (i) => i).map((m) {
                          return DropdownMenuItem(value: m, child: Text('$m'));
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selMonths = value!;
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
                    final saved = '${selYears}y ${selMonths}m';
                    final prefs  = await SharedPreferences.getInstance();
                    final agePref = await LoginService.key('phone_age');
                    final setDatePref = await LoginService.key('phone_age_set_date');
                    // Only reset the set date if the value changed
                    if (saved != prefs.getString(agePref)) {
                      await prefs.setString(setDatePref, DateTime.now().toIso8601String());
                    }
                    await prefs.setString(agePref, saved);
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

  //Charging Habits selection
  void _showChargingHabitDialog() {
    // Parse existing saved value back into cycles
    double selectedCycles = 0;
    final existing = double.tryParse(_cycles);
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
                'You complete one charge cycle when you\'ve used (discharged) an amount that represents 100% of your battery\'s capacity BUT not necessarily all from one charge. ',
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
                final cycles = await LoginService.key('charging_habit');
                await prefs.setString(cycles, saved);
                if (!mounted) return;
                setState(() {
                  _cycles = saved;
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

  // Brand selection dialog
  void _showBrandDialog() {
    final List<String> brands = ['Apple', 'Samsung', 'Google', 'Other'];
    String selBrand = _phoneBrand.isEmpty ? 'Other' : _phoneBrand;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Phone Brand'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Brand', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selBrand,
                    isExpanded: true,
                    items: brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (v) => setDialogState(() => selBrand = v!),
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
                    final prefs = await SharedPreferences.getInstance();
                    final phoneBrand = await LoginService.key('phone_brand');
                    await prefs.setString(phoneBrand, selBrand);
                    if (!mounted) return;
                    setState(() {
                      _phoneBrand = selBrand;
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
            
            AppHeader(
              userName: _userName,
              subtitle: 'Here are your settings',
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
                      onTap: _showAccountDialog,
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
                      title: const Text('Phone Brand', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        _phoneBrand.isEmpty ? 'Not set' : _phoneBrand,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: _showBrandDialog,
                    ),

                    const Divider(height: 1, color: Colors.black12),

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
                        _cycles.isEmpty ? 'Not set' : '$_cycles cycles per day',
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

            //Notifications section
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
                        onChanged: _toggleNotifications,
                        activeThumbColor: Colors.deepPurple,
                      ),
                      onTap: () => _toggleNotifications(!_notificationsEnabled),
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
                    onTap: () async {
                      await LoginService.logout();
                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),

                  const Divider(height: 1, color: Colors.black12),

                  // delete account - permanently removes account and all data
                  ListTile(
                    title: const Text('Delete Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.red),
                    onTap: () async {
                      // confirm before deleting
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text('This will permanently delete your account and all your data. This cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await LoginService.deleteAccount();
                        if (!mounted) return;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                        );
                      }
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