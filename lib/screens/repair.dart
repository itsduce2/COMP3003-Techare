import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/dialog/troubleshooting_survey.dart';
import '../widgets/dialog/tutorial_preview.dart';
import '../widgets/dialog/tutorial_steps.dart';
import '../data/tutorials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/device_info_service.dart';
import '../services/login_service.dart';

class RepairScreen extends StatefulWidget {
  const RepairScreen({super.key});

  @override
  State<RepairScreen> createState() => _RepairScreenState();
}

class _RepairScreenState extends State<RepairScreen> {

  String _userName = '';

  // Device info variables
  String _deviceName = 'Your Device';

  // brand loaded from shared prefs - apple shows ios tutorial, everything else shows android
  String _phoneBrand = 'Other';

  // Category variables
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Battery', 'Storage', 'Overheating'];

  List<Tutorial> get _tutorialsForBrand => tutorialsForBrand(_phoneBrand);

  List<Tutorial> get _sortedTutorials {
    if (_selectedCategory == 'All') return _tutorialsForBrand;
    return _tutorialsForBrand.where((t) => t.category == _selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadDeviceName();
    _loadBrand();
  }

  Future<void> _loadUserName() async {
    final name = await LoginService.currentUserName();
    setState(() => _userName = name);
  }

  // calls the service to get device name
  Future<void> _loadDeviceName() async {
    final data = await DeviceInfoService.getDeviceDetails();
    setState(() {
      _deviceName = data['name'] ?? 'Your Device';
    });
  }

  // loads saved brand - if apple show ios tutorial else show android tutorial
  Future<void> _loadBrand() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneBrand = prefs.getString('phone_brand') ?? 'Other';
    });
  }

  // opens the troubleshooting survey dialog
  void _openTroubleshootingSurvey() {
    showDialog(
      context: context,
      builder: (context) => TroubleshootingSurveyDialog(
        onComplete: (category) {
          Navigator.pop(context);
          setState(() => _selectedCategory = category);
        },
      ),
    );
  }

  // opens the tutorial preview dialog
  void _openTutorialPreview(Tutorial tutorial) {
    showDialog(
      context: context,
      builder: (context) => TutorialPreviewDialog(
        tutorial: tutorial,
        onStart: () {
          Navigator.pop(context);
          _openTutorialSteps(tutorial);
        },
      ),
    );
  }

  // opens the tutorial steps dialog
  void _openTutorialSteps(Tutorial tutorial) {
    showDialog(
      context: context,
      builder: (context) => TutorialStepsDialog(tutorial: tutorial),
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
                subtitle: 'Repair your device',
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
                                        tutorial.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      //padding
                                      const SizedBox(height: 4),
                                      Text(
                                        tutorial.description,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      //padding
                                      const SizedBox(height: 8),
                                      Text(
                                        tutorial.duration,
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