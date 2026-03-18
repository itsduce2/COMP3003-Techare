import 'package:flutter/material.dart';
import '../device_info_service.dart';
import '../battery_service.dart';
import '../storage_service.dart';

// Diagnostics tab — lets the user run a scan and view a history of past results.
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {

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

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  // calls the service to get device data
  Future<void> _loadDeviceData() async {
    final data = await DeviceInfoService.getDeviceDetails();
    setState(() {
      _deviceName = data['name'] ?? 'Unknown';
      _deviceOS = data['os'] ?? 'Unknown';
    });
  }

  // calls the battery service to load battery data
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
      } else {
        _batteryHealth = healthString[0].toUpperCase() + healthString.substring(1).toLowerCase();
      }
    });
  }

  // calls the storage service to load storage data
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

  //initialises the dasboard
  Future<void> _initDashboard() async {
    await Future.wait([
      _loadDeviceData(),
      _loadBatteryData(),
      _loadStorageData(),
    ]);
    _calculateOverallHealth();
  }

  void _calculateOverallHealth() {
    setState(() {
      String health = _batteryHealth;
      
      // Poor = critical battery or storage nearly full (>= 95%)
      if (health == 'Failed' || health == 'Overheated' ||
          health == 'Overvoltage' || health == 'Dead' ||
          _storagePercent >= 95) {
        _healthStatus = 'Poor';
        _statusColor = Colors.red;
        _healthMessage = 'Critical issues detected';
      }
      
      // Fair = low battery (<= 20%) or high storage (>= 85%)
      else if (_batteryLevel <= 20 || _storagePercent >= 85) {
        _healthStatus = 'Fair';
        _statusColor = Colors.orange;
        _healthMessage = 'Some issues detected';
      } 
      // Good = everything looks fine
      else {
        _healthStatus = 'Good';
        _statusColor = Colors.green;
        _healthMessage = 'Overall good health';
      }
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
                        'Here are your diagnostics',
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

              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 24),

                    // AI prediction button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          //placeholder for AI feature
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Get AI Prediction',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
                        ),
                      ),
                    ),

                    //padding
                    const SizedBox(height: 32),

                    // Recent results section
                    const Text('Recent Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    
                    //padding
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      //layout row
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('November 9, 2025', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Battery Health 70%; Low Storage', style: TextStyle(fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              // not implemented yet
                            },
                            child: const Text('View', style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),

                    //padding
                    const SizedBox(height: 24),

                    // Run diagnostic button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () {
                          //placeholder for diagnostic
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Run Diagnostics',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),

                    //padding
                    const SizedBox(height: 32),

                    // Previous results section
                    const Text('Previous Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    
                    //padding
                    const SizedBox(height: 12),

                    // Placeholder for results
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.history, color: Colors.grey, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'No previous scans',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          SizedBox(height: 4)
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