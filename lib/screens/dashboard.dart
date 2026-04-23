import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../services/device_info_service.dart';
import '../services/battery_service.dart';
import '../services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/login_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  // Device info variables
  String _deviceName = 'Loading device info...';
  String _deviceOS = 'Loading OS info...';
  
  // Battery variables
  int _batteryLevel = 0;
  String _batteryHealth = 'Loading...';
  String _batteryTemperature = 'Loading...';

  // Storage variables
  double _storagePercent = 0.0;
  String _storageText = 'Loading...';
  bool _isLowSpace = false;

  // Overall health variables
  String _healthStatus = 'Loading...';
  String _healthMessage = 'Loading...'; 
  Color _statusColor = Colors.white;

  String _userName = '';

  // Diagnostic variables
  bool _isScanning = false;
  String _lastScanDate = 'Never';


  

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadDeviceData();
    _loadBatteryData();
    _loadStorageData();
    _loadLastScanDate();
    _initDashboard();
  }

  Future<void> _loadUserName() async {
    final name = await LoginService.currentUserName();
    setState(() => _userName = name);
  }

  Future<void> _loadLastScanDate() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await LoginService.key('last_scan_date');
    setState(() {
      _lastScanDate = prefs.getString(key) ?? 'Never';
    });
  }

  Future<void> _saveLastScanDate() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await LoginService.key('last_scan_date');
    String now = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    await prefs.setString(key, now);
    setState(() {
      _lastScanDate = now;
    });
  }

  Future<void> _savePreviousResult() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsKey     = await LoginService.key('previous_results');
    final healthKey      = await LoginService.key('last_battery_health');
    final storageKey     = await LoginService.key('last_storage_percent');
    final tempKey        = await LoginService.key('last_battery_temperature');
    final String now = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    final String newEntry =
        '$now|$_healthStatus|$_batteryLevel% ($_batteryHealth)|$_storageText|$_batteryTemperature';
    final List<String> existing = prefs.getStringList(resultsKey) ?? [];
    existing.insert(0, newEntry);
    await prefs.setStringList(resultsKey, existing);
    await prefs.setString(healthKey, _batteryHealth);
    await prefs.setString(storageKey, _storagePercent.toString());
    await prefs.setString(tempKey, _batteryTemperature);
  }

  Future<void> _handleDiagnostic() async {
    // Start the loading spinner
    setState(() => _isScanning = true);
    
    await Future.delayed(const Duration(seconds: 2));
    
    await _initDashboard();    // Refresh
    await _saveLastScanDate(); 
    await _savePreviousResult();

    // Stop the loading spinner and show results
    setState(() => _isScanning = false);
    _showResultsPopup();
  }

  // loads device data and updates state
  Future<void> _loadDeviceData() async {
    final data = await DeviceInfoService.getDeviceDetails();
    setState(() {
      _deviceName = data['name'] ?? 'Unknown';
      _deviceOS = data['os'] ?? 'Unknown';
    });
  }

  // loads battery data and updates state
  Future<void> _loadBatteryData() async {
    final data = await BatteryService.getBatteryInfo();

    String healthString = data['health'] ?? 'Unknown';

    setState(() {
      _batteryLevel = data['level'] ?? 0;
      _batteryTemperature = data['temperature'] ?? 'Unknown';

      if (healthString == 'unspecifiedfailure') {
        _batteryHealth = 'Unspecified Failure';
      } else if (healthString == 'overheat') {
        _batteryHealth = 'Overheated';
       }
      
      else {
        _batteryHealth = healthString[0].toUpperCase() + healthString.substring(1).toLowerCase();
      }      
    });
  }

  // loads storage data and updates state
  Future<void> _loadStorageData() async {
      try {
        final storage = await StorageService().getStorageDetails();
        setState(() {
          _storagePercent = storage.usageValue * 100;
          _storageText = '${_storagePercent.toStringAsFixed(0)}% Used';
          _isLowSpace = _storagePercent >= 95;        
        });
      } catch (e) {
        debugPrint("Failed to get storage data: $e");
      }
    }
  
  // Init dashboard loading all data and calculating health after all are loaded
  Future<void> _initDashboard() async {
    await Future.wait([
      _loadDeviceData(),
      _loadBatteryData(),
      _loadStorageData(),
    ]);
    _calculateOverallHealth();
  }

  // build method to draw the UI
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
            
            AppHeader(
              userName: _userName,
              subtitle: 'Welcome to Techare',
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
                      color: _statusColor == Colors.white ? Colors.orange[50] : _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline, 
                          size: 40, 
                          color: _statusColor == Colors.white ? Colors.orange : _statusColor
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _healthStatus, // Just a variable
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _healthMessage, // Just a variable
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
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
                            children: [
                              Text('Battery', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              _batteryIcon(),
                              const SizedBox(height: 12),
                              Text('Level: $_batteryLevel%', style: TextStyle(fontSize: 12)),
                              Text(_batteryHealth, style: TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
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
                            children: [
                              const Text('Storage', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              _storageIcon(),
                              const SizedBox(height: 12),
                              Text(_storageText, style: const TextStyle(fontSize: 14)),
                              Text(
                                _isLowSpace ? 'Warning: Low space' : 'Low usage', 
                                style: TextStyle(fontSize: 12, color: _isLowSpace ? Colors.red : Colors.black54), 
                                textAlign: TextAlign.center
                              ),
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
                            children: [
                              const Text('Temperature', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              _temperatureIcon(),
                              const SizedBox(height: 12),
                              const Text('Normal:', style: TextStyle(fontSize: 12)),
                              Text('Temp: $_batteryTemperature', style: const TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),                            ],
                          ),
                        ),
                      ),

                    ],
                  ),

                  // padding
                  const SizedBox(height: 32), 

                  // Run diagnostic button
                  SizedBox(
                    width: double.infinity, // Full width
                    height: 56, 
                    child: ElevatedButton(
                      // Logic: If scanning, disable button; otherwise run diagnostic
                      onPressed: _isScanning ? null : _handleDiagnostic,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Your original 12
                        ),
                      ),
                      child: _isScanning 
                        ? const SizedBox(
                            height: 24, 
                            width: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : const Text(
                            'Run Diagnostic',
                            style: TextStyle(
                              fontSize: 18,        // Your original size
                              fontWeight: FontWeight.bold, // Your original weight
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
                          children: [
                            const Text('Recent Diagnostic', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('(Last Scan: $_lastScanDate)', style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                        TextButton(
                          onPressed: _showResultsPopup, 
                          child: const Text('View Results')
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
                  
                  //padding
                  const SizedBox(height: 12), 
                  
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

  void _calculateOverallHealth() {
    setState(() {
      String health = _batteryHealth;

      if (health == 'Failed' || health == 'Overheated' ||
        health == 'Overvoltage' || health == 'Dead' || health == 'Unspecified Failure' ||
        _storagePercent >= 95) {
          _healthStatus = 'Poor';
          _statusColor = Colors.red;
          _healthMessage = 'Critical issues detected';
          
          } 

      else if (_batteryLevel <= 20 || _storagePercent >= 85) {
        _healthStatus = 'Fair';
        _statusColor = Colors.orange;
        _healthMessage = 'Some issues detected';
      } 

      else {
        _healthStatus = 'Good';
        _statusColor = Colors.green;
        _healthMessage = 'Overall good health';
      }
    });
  }

  Widget _batteryIcon() {
    final health = _batteryHealth.toLowerCase();
    final bool hasCriticalHealth = health.contains('failed') ||
        health.contains('overheat') ||
        health.contains('overvoltage') ||
        health.contains('dead');

    if (hasCriticalHealth || _batteryLevel <= 20) {
      return const Icon(Icons.battery_alert, size: 32, color: Colors.red);
    } else if (_batteryLevel <= 40) {
      return const Icon(Icons.battery_2_bar, size: 32, color: Colors.orange);
    } else {
      return const Icon(Icons.battery_charging_full, size: 32, color: Colors.green);
    }
  }

  Widget _storageIcon() {
    if (_storagePercent >= 95) {
      return const Icon(Icons.storage, size: 32, color: Colors.red);
    } else if (_storagePercent >= 85) {
      return const Icon(Icons.storage, size: 32, color: Colors.orange);
    } else {
      return const Icon(Icons.storage, size: 32, color: Colors.green);
    }
  }

  Widget _temperatureIcon() {
    final String temp = _batteryTemperature.replaceAll('°C', '').trim();
    final int? batteryTemp = int.tryParse(temp);

    // error handling /still loading
    if (batteryTemp == null) {
      return const Icon(Icons.thermostat, size: 32, color: Colors.grey);
    }

    if (batteryTemp >= 36) {
      return const Icon(Icons.thermostat, size: 32, color: Colors.red);
    } else {
      return const Icon(Icons.thermostat, size: 32, color: Colors.green);
    }
  }

  void _showResultsPopup() {

    if (_healthStatus == 'Loading...') return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnostic Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Fits the popup to the content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_healthStatus', style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold)),
            const Divider(),
            Text('Message: $_healthMessage'),
            const SizedBox(height: 10),
            Text('Storage: $_storageText'),
            Text('Battery: $_batteryLevel% ($_batteryHealth)'),
            Text('Temperature: $_batteryTemperature'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Close')
          ),
        ],
      ),
    );
  }

}