import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildFeatureSlide(String title, String desc, Color color) {
    return Container(
      color: color.withOpacity(0.1),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 40),
          ElevatedButton(onPressed: _nextPage, child: const Text("Next")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Slide 1
          Center(
            child: ElevatedButton(onPressed: _nextPage, child: const Text("Get Started")),
          ),
          // Slide 2
          _buildFeatureSlide("Track Health", "Monitor your battery cycles effectively.", Colors.blue),
          // Slide 3
          _buildFeatureSlide("Smart Alerts", "Get notified when your battery needs care.", Colors.purple),
        ],
      ),
    );
  }
}