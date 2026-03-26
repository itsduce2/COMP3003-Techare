import 'package:flutter/material.dart';
import '../device_info_service.dart';

class RepairScreen extends StatefulWidget {
  const RepairScreen({super.key});

  @override
  State<RepairScreen> createState() => _RepairScreenState();
}

class _RepairScreenState extends State<RepairScreen> {

  // Device info variables
  String _deviceName = 'Your Device';

  // Category variables
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Battery', 'Storage', 'Overheating'];

  // Tutorial variables
  final List<Map<String, dynamic>> _allTutorials = [
    {
      // replace battery
      'title': 'Replace Battery',
      'description': 'Remove screen, disconnect battery cable, replace battery...',
      'duration': '45min',
      'category': 'Battery',
      'tools': ['Small cross screwdriver', 'Replacement battery'],
      'warning':
          'Repairing your device involves delicate components. Removing your screen or replacing the battery may cause permanent damage if not done correctly. Proceed only if you\'re experienced and follow proper safety steps.',
      'steps': [
        {
          'title': 'Power Off the Device',
          'description':
              'Turn off your phone completely to prevent electrical damage or accidental input during the repair.',
        },
        {
          'title': 'Remove the Back Cover',
          'description':
              'Use a small cross screwdriver to remove the screws on the back cover. Carefully pry off the cover using a plastic spudger.',
        },
        {
          'title': 'Disconnect the Battery Cable',
          'description':
              'Locate the battery connector and gently disconnect it from the motherboard.',
        },
        {
          'title': 'Remove the Old Battery',
          'description':
              'Use a plastic spudger to carefully lift the battery. Avoid puncturing it.',
        },
        {
          'title': 'Insert the New Battery',
          'description':
              'Place the new battery in the same position and reconnect the battery cable.',
        },
        {
          'title': 'Reassemble and Test',
          'description':
              'Replace the back cover, screw it in, then power on the device to verify the repair.',
        },
      ],
    },
    
    //Fix overheating
    {
      'title': 'Fix Overheating',
      'description': 'Close background apps, check charging habits, update software...',
      'duration': '5min',
      'category': 'Overheating',
      'tools': [],
      'warning': '',
      'steps': [
        {
          'title': 'Close Background Apps',
          'description':
              'Open your recent apps and close all unnecessary applications running in the background.',
        },
        {
          'title': 'Check Charging Habits',
          'description':
              'Avoid using your phone while charging. Use the original charger to prevent overheating.',
        },
        {
          'title': 'Update Your Software',
          'description':
              'Go to Settings > System > Software Update and install any available updates.',
        },
        {
          'title': 'Reset Network Settings',
          'description':
              'If overheating persists, go to Settings > General > Reset > Reset Network Settings.',
        },
        {
          'title': 'Monitor Temperature',
          'description':
              'Use the Techare diagnostics tool to keep monitoring your device temperature.',
        },
      ],
    },

    {
      'title': 'Storage Performance Reduction',
      'description': 'Clear cache, uninstall unused apps, move photos to cloud...',
      'duration': '1min',
      'category': 'Storage',
      'tools': [],
      'warning': '',
      'steps': [
        {
          'title': 'Open Storage Settings',
          'description':
              'Go to Settings > Storage to see what is taking up space on your device.',
        },
        {
          'title': 'Clear App Cache',
          'description':
              'Tap on individual apps and select "Clear Cache" to free up space without deleting data.',
        },
        {
          'title': 'Delete Unused Apps',
          'description':
              'Remove apps you no longer use. Long-press an app icon and select Uninstall.',
        },
        {
          'title': 'Move Photos to Cloud',
          'description':
              'Back up your photos to Google Photos or another cloud service, then delete local copies.',
        },
      ],
    },
    //improve battery life
    {
      'title': 'Improve Battery Life',
      'description': 'Adjust brightness, disable background refresh, enable battery saver...',
      'duration': '2min',
      'category': 'Battery',
      'tools': [],
      'warning': '',
      'steps': [
        {
          'title': 'Reduce Screen Brightness',
          'description':
              'Lower your screen brightness or enable adaptive brightness in Settings > Display.',
        },
        {
          'title': 'Enable Battery Saver',
          'description':
              'Go to Settings > Battery > Battery Saver and turn it on.',
        },
        {
          'title': 'Disable Background App Refresh',
          'description':
              'Go to Settings > Apps and restrict background activity for apps you don\'t need running constantly.',
        },
        {
          'title': 'Check Battery Usage',
          'description':
              'Go to Settings > Battery > Battery Usage to identify which apps are draining your battery most.',
        },
      ],
    },

  ];

  List<Map<String, dynamic>> get _sortedTutorials {
    if (_selectedCategory == 'All') return _allTutorials;
    return _allTutorials.where((t) => t['category'] == _selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadDeviceName();
  }

  // calls the service to get device name
  Future<void> _loadDeviceName() async {
    final data = await DeviceInfoService.getDeviceDetails();
    setState(() {
      _deviceName = data['name'] ?? 'Your Device';
    });
  }

  // opens the tutorial preview dialog
  void _openTutorialPreview(Map<String, dynamic> tutorial) {
    showDialog(
      context: context,
      builder: (context) => _TutorialPreviewDialog(tutorial: tutorial),
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
                          'Repair your device',
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Troubleshooting survey card
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Troubleshooting Survey',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  
                                  //padding
                                  SizedBox(height: 4),
                                  
                                  Text(
                                    'Answer a few quick questions so we can understand your device\'s symptoms',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  
                                  //padding
                                  SizedBox(height: 8),
                                  
                                  Text(
                                    '3min',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.deepPurpleAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    //padding
                    const SizedBox(height: 24),

                    // Category filter tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final bool isSelected = _selectedCategory == cat;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () => setState(() => _selectedCategory = cat),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.deepPurpleAccent : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    //padding
                    const SizedBox(height: 16),

                    // Top results label
                    const Text(
                      'Top Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    //padding
                    const SizedBox(height: 12),

                    // Tutorial cards
                    if (_sortedTutorials.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No tutorials found for this category.',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      )
                    else
                      ...(_sortedTutorials.map(
                        (tutorial) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tutorial['title'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      //padding
                                      const SizedBox(height: 4),
                                      Text(
                                        tutorial['description'],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      //padding
                                      const SizedBox(height: 8),
                                      Text(
                                        tutorial['duration'],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //padding
                                const SizedBox(width: 12),
                                FilledButton(
                                  onPressed: () => _openTutorialPreview(tutorial),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.deepPurpleAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text(
                                    'Start',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),

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

class _TutorialPreviewDialog extends StatelessWidget {
  final Map<String, dynamic> tutorial;

  const _TutorialPreviewDialog({required this.tutorial});

  @override
  Widget build(BuildContext context) {
    final List<String> tools = List<String>.from(tutorial['tools']);
    final String warning = tutorial['warning'];

    return AlertDialog(
      title: Text(tutorial['title']),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // tools section
            if (tools.isNotEmpty) ...[
              const Text(
                'Tools Required',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              //padding
              const SizedBox(height: 8),
              ...tools.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $t', style: const TextStyle(fontSize: 14)),
                ),
              ),
              //padding
              const SizedBox(height: 12),
              InkWell(
                onTap: () {},
                child: const Text(
                  'Buy spare parts',
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              //padding
              const SizedBox(height: 16),
            ],

            // warning section
            if (warning.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    //padding
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Warning',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          //padding
                          const SizedBox(height: 4),
                          Text(
                            warning,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
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
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
          ),
          child: const Text('Start Tutorial'),
        ),
      ],
    );
  }
}