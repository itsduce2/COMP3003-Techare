import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.health_and_safety_outlined,
      'title': 'Run diagnostics in seconds',
      'subtitle': 'Get a full picture of your battery, storage and temperature at any time.',
    },
    {
      'icon': Icons.auto_awesome_outlined,
      'title': 'Predict battery health months ahead',
      'subtitle': 'Our AI model uses real battery research to forecast your device\'s future health.',
    },
    {
      'icon': Icons.handyman_outlined,
      'title': 'Get guided repair tutorials',
      'subtitle': 'Step-by-step repair guides with tool lists and safety warnings.',
    },
  ];

  void _nextPage() {
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (int page) => setState(() => _currentPage = page),
        children: [
          _buildWelcomeScreen(),
          ..._features.map((f) => _buildFeatureSlide(f)).toList(),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, size: 120, color: Colors.deepPurple),
          const SizedBox(height: 40),
          const Text("Your phone is ageing.", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 48),
          _buildWideButton("Get Started", _nextPage),
        ],
      ),
    );
  }

  Widget _buildFeatureSlide(Map<String, dynamic> feature) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(feature['icon'], size: 80, color: Colors.deepPurple),
            const SizedBox(height: 32),
            Text(feature['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(feature['subtitle'], style: const TextStyle(fontSize: 16, color: Colors.black54), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            _buildPageIndicator(),
            const SizedBox(height: 32),
            _buildWideButton("Continue", _nextPage),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = (_currentPage - 1) == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(color: isActive ? Colors.deepPurple : Colors.grey[300], borderRadius: BorderRadius.circular(4)),
        );
      }),
    );
  }

  Widget _buildWideButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}