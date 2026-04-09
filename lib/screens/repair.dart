import 'package:flutter/material.dart';
import '../device_info_service.dart';

const List<Map<String, dynamic>> _surveyQuestions = [
  {
    'question': 'What is the main issue you\'re experiencing?',
    'options': [
      'Battery draining quickly',
      'Device overheating',
      'Running out of storage',
      'Device running slowly',
      'Other',
    ],
  },
  {
    'question': 'How long has this been happening?',
    'options': [
      'Just started today',
      'A few days',
      'A week or more',
      'Always been an issue',
    ],
  },
  {
    'question': 'How severe is the issue?',
    'options': [
      'Minor (little impact on use)',
      'Moderate (affects daily use)',
      'Severe (device is barely usable)',
    ],
  },
];

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

    // Fix overheating
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

    // Storage performance reduction
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

    // Improve battery life
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

  // opens the troubleshooting survey dialog
  void _openTroubleshootingSurvey() {
    showDialog(
      context: context,
      builder: (context) => _TroubleshootingSurveyDialog(
        onComplete: (category) {
          Navigator.pop(context);
          setState(() => _selectedCategory = category);
        },
      ),
    );
  }

  // opens the tutorial preview dialog
  void _openTutorialPreview(Map<String, dynamic> tutorial) {
    showDialog(
      context: context,
      builder: (context) => _TutorialPreviewDialog(
        tutorial: tutorial,
        onStart: () {
          Navigator.pop(context);
          _openTutorialSteps(tutorial);
        },
      ),
    );
  }

  // opens the tutorial steps dialog
  void _openTutorialSteps(Map<String, dynamic> tutorial) {
    showDialog(
      context: context,
      builder: (context) => _TutorialStepsDialog(tutorial: tutorial),
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
                      onTap: _openTroubleshootingSurvey,
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

//survey options and logic
class _TroubleshootingSurveyDialog extends StatefulWidget {
  final void Function(String category) onComplete;

  const _TroubleshootingSurveyDialog({required this.onComplete});

  @override
  State<_TroubleshootingSurveyDialog> createState() => _TroubleshootingSurveyDialogState();
}

class _TroubleshootingSurveyDialogState extends State<_TroubleshootingSurveyDialog> {

  // Survey variables
  int _step = 0;
  String? _selectedAnswer;
  String? _firstAnswer;

  // maps the first answer to a category
  String _mapToCategory(String answer) {
    final String lower = answer.toLowerCase();
    if (lower.contains('battery')) return 'Battery';
    if (lower.contains('overheating')) return 'Overheating';
    if (lower.contains('storage')) return 'Storage';
    return 'All';
  }

  // moves to the next or completes
  void _next() {
    if (_selectedAnswer == null) return;
    if (_step == 0) _firstAnswer = _selectedAnswer;
    if (_step < _surveyQuestions.length - 1) {
      setState(() {
        _step++;
        _selectedAnswer = null;
      });
    } else {
      widget.onComplete(_mapToCategory(_firstAnswer ?? ''));
    }
  }

  void _back() {
    setState(() {
      _step--;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> question = _surveyQuestions[_step];
    final List<String> options = List<String>.from(question['options']);

    return AlertDialog(
      title: Text('Question ${_step + 1} of ${_surveyQuestions.length}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              question['question'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            //padding
            const SizedBox(height: 12),

            // answer options
            ...options.map(
              (option) => RadioListTile<String>(
                title: Text(option, style: const TextStyle(fontSize: 14)),
                value: option,
                groupValue: _selectedAnswer,
                activeColor: Colors.deepPurpleAccent,
                contentPadding: EdgeInsets.zero,
                dense: true,
                onChanged: (val) => setState(() => _selectedAnswer = val),
              ),
            ),

          ],
        ),
      ),
      actions: [

        // only show Back if not on first question
        if (_step > 0)
          TextButton(
            onPressed: _back,
            child: const Text('Back'),
          ),

        FilledButton(
          onPressed: _selectedAnswer == null ? null : _next,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
          ),
          child: Text(
            _step < _surveyQuestions.length - 1 ? 'Next' : 'See Results',
          ),
        ),

      ],
    );
  }
}

// tutorial preview 
class _TutorialPreviewDialog extends StatelessWidget {
  final Map<String, dynamic> tutorial;
  final VoidCallback onStart;

  const _TutorialPreviewDialog({
    required this.tutorial,
    required this.onStart,
  });

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
                  'Buy spare parts ↗',
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
          onPressed: onStart,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
          ),
          child: const Text('Start Tutorial'),
        ),
      ],
    );
  }
}

//tutorial steps
class _TutorialStepsDialog extends StatefulWidget {
  final Map<String, dynamic> tutorial;

  const _TutorialStepsDialog({required this.tutorial});

  @override
  State<_TutorialStepsDialog> createState() => _TutorialStepsDialogState();
}

class _TutorialStepsDialogState extends State<_TutorialStepsDialog> {

  // Step variables
  int _currentStep = 0;

  List<Map<String, dynamic>> get _steps =>
      List<Map<String, dynamic>>.from(widget.tutorial['steps']);

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    final step = steps[_currentStep];
    final int total = steps.length;
    final bool isLast = _currentStep == total - 1;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${_currentStep + 1} of $total',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          //padding
          const SizedBox(height: 4),
          Text(
            widget.tutorial['title'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // tutorial icons
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.smartphone, size: 60, color: Colors.grey),
            ),
          ),

          //padding
          const SizedBox(height: 16),

          Text(
            step['title'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          //padding
          const SizedBox(height: 8),

          Text(
            step['description'],
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.center,
          ),

        ],
      ),
      actions: [

        // only show previous if not on first step
        if (_currentStep > 0)
          OutlinedButton(
            onPressed: () => setState(() => _currentStep--),
            child: const Text('Previous'),
          ),

        FilledButton(
          onPressed: () {
            if (!isLast) {
              setState(() => _currentStep++);
            } else {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.tutorial['title']} tutorial complete!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
          ),
          child: Text(isLast ? 'Finish' : 'Next'),
        ),

      ],
    );
  }
}