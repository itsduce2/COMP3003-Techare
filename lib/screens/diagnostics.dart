import 'package:flutter/material.dart';
import '../device_info_service.dart';
import '../battery_service.dart';
import '../storage_service.dart';
import '../battery_prediction_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/perdiction.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => DiagnosticsScreenState();
}

class DiagnosticsScreenState extends State<DiagnosticsScreen> {

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

  // Overall health variables
  String _healthStatus = 'Loading...';
  String _healthMessage = 'Loading...';
  Color _statusColor = Colors.white;

  // Diagnostic variables
  bool _isScanning = false;
  bool _isPredicting = false;
  String _lastScanDate = 'Never';

  // Previous results list
  List<Map<String, String>> _previousResults = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> refresh() async {
  await _loadLastScanDate();
  await _loadPreviousResults();
  }

  // loads saved history and last scan date at the same time, then fetches fresh sensor data
  Future<void> _init() async {
    await Future.wait([
      _loadLastScanDate(),
      _loadPreviousResults(),
    ]);
    await _initDashboard();
  }

  // loads the last scan date from storage
  Future<void> _loadLastScanDate() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastScanDate = prefs.getString('last_scan_date') ?? 'Never';
    });
  }

  // saves the current scan date to now 
  Future<void> _saveLastScanDate() async {
    final prefs = await SharedPreferences.getInstance();
    String now = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    await prefs.setString('last_scan_date', now);
    setState(() {
      _lastScanDate = now;
    });
  }

  // loads the previous scan results from storage
  Future<void> _loadPreviousResults() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList('previous_results');
    if (stored != null) {
      setState(() {
        _previousResults = stored.map((entry) {
          final res = entry.split('|');
          return {
            'date': res[0],
            'status': res[1],
            'battery': res[2],
            'storage': res[3],
            'temperature': res[4],
          };
        }).toList();
      });
    }
  }

  // saves the current scan result to the history
  Future<void> _savePreviousResult() async {
    final prefs = await SharedPreferences.getInstance();
    final String now = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    final Map<String, String> newEntry = {
      'date': now,
      'status': _healthStatus,
      'battery': '$_batteryLevel% ($_batteryHealth)',
      'storage': _storageText,
      'temperature': _batteryTemperature,
    };

    await prefs.setString('last_battery_health', _batteryHealth);
    await prefs.setString('last_storage_percent', _storagePercent.toString());
    await prefs.setString('last_battery_temperature', _batteryTemperature);

    // LIFO for scan results
    _previousResults.insert(0, newEntry);
    final List<String> encoded = _previousResults.map((e) =>
      '${e['date']}|${e['status']}|${e['battery']}|${e['storage']}|${e['temperature']}'
    ).toList();
    await prefs.setStringList('previous_results', encoded);
    setState(() {});
  }

  // clears diagnostic history
  Future<void> _clearAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('previous_results');
    await prefs.remove('last_scan_date');
    setState(() {
      _previousResults = [];
      _lastScanDate = 'Never';
    });
  }

  // user confirmation to clear scan history
  void _confirmClear() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Results'),
        content: const Text('This will permanently delete all previous scan history. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllResults();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // handling for 'Get AI Prediction' button
  Future<void> _handlePrediction() async {
    setState(() => _isPredicting = true);
    await Future.delayed(const Duration(seconds: 2));    
    final result = await BatteryPredictionService.predict();
    setState(() => _isPredicting = false);
    if (!mounted) return;
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => Prediction(result: result)),
);
  }

  // handling for 'Run Diagnostics' button
  Future<void> _handleDiagnostic() async {
    // spinner and delay
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 2));
    
    // refresh all sensors
    await _initDashboard();
    
    // save the date and add to history
    await _saveLastScanDate();
    await _savePreviousResult();
    
    setState(() => _isScanning = false);
    _showResultsPopup();
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

  // popup for diagnostic results
  void _showResultsPopup() {
    if (_healthStatus == 'Loading...') return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnostic Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_healthStatus', style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold)),
            const Divider(),
            Text('Message: $_healthMessage'),
            const SizedBox(height: 10),
            Text('Storage: $_storageText'),
            Text('Battery: $_batteryLevel% ($_batteryHealth)'),
            Text('Temperature: $_batteryTemperature'),
            
            //padding 
            const SizedBox(height: 15), 

            const Text(
              'Still having issues with your device?',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            
            //troubleshooting button NOT FINISHED YET
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                // need to add troubleshooting surey
                onPressed: () => Navigator.pop(context),

                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurpleAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Troubleshoot Device',
                  style: TextStyle(color: Colors.deepPurpleAccent),
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurpleAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () => Navigator.pop(context),
        //     child: const Text('Close'),
        //   ),
        // ],
      ),
    );
  }

  // view button popup 
  void _showHistoryPopup(Map<String, String> result) {
    final String status = result['status'] ?? 'Unknown';
    Color statusColor = Colors.green;
    if (status == 'Poor') statusColor = Colors.red;
    if (status == 'Fair') statusColor = Colors.orange;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan: ${result['date']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $status', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            const Divider(),
            Text('Battery: ${result['battery']}'),
            Text('Storage: ${result['storage']}'),
            Text('Temperature: ${result['temperature']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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
                        onPressed: _isPredicting ? null : _handlePrediction,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isPredicting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.deepPurpleAccent, strokeWidth: 3),
                              )
                            : const Text(
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

                    // Card showing the most recent scan with a View button
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
                          //last scan date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _lastScanDate == 'Never' ? 'No recent scan' : _lastScanDate,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              //summary of results 
                              Text(
                                _lastScanDate == 'Never'
                                    ? 'Run a diagnostic to see results'
                                    : '$_healthStatus: Battery $_batteryLevel%; $_storageText',
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                          // opens the results popup
                          InkWell(
                            onTap: _showResultsPopup,
                            child: const Text('View', style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),

                    //padding
                    const SizedBox(height: 24),

                    // Run diagnostics button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        // disabled while a scan is already running
                        onPressed: _isScanning ? null : _handleDiagnostic,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        // show spinner while scanning
                        child: _isScanning
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : const Text(
                                'Run Diagnostics',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),

                    //padding
                    const SizedBox(height: 32),

                    // Previous results header with clear button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Previous Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        // only show Clear when there is something to clear
                        if (_previousResults.isNotEmpty)
                          TextButton.icon(
                            onPressed: _confirmClear,
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            label: const Text('Clear', style: TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),

                    //padding
                    const SizedBox(height: 12),

                    // list of previous scans or isEmpty message
                    if (_previousResults.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No previous scans yet. Run a diagnostic to get started.',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      )
                    else
                      // map each saved result to a card
                      Column(
                        children: _previousResults.map((result) {
                          final String status = result['status'] ?? 'Unknown';
                          // colour dot fro health status indicator
                          Color statusColor = Colors.green;
                          if (status == 'Poor') statusColor = Colors.red;
                          if (status == 'Fair') statusColor = Colors.orange;

                          return Padding(
                            //spacing between cards
                            padding: const EdgeInsets.only(bottom: 12.0),
                            
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result['date'] ?? '',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.circle, size: 10, color: statusColor),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$status: Battery ${result['battery']}',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  
                                  // previous scan popup
                                  InkWell(
                                    onTap: () => _showHistoryPopup(result),
                                    child: const Text('View', style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.w600, fontSize: 16)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    //padding
                    const SizedBox(height: 16),

                    // Clear history button (only shown when there is history to clear)
                    if (_previousResults.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _confirmClear,
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text(
                            'Clear History',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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