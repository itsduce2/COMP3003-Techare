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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildWelcomeScreen(),
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
          const Text(
            "Your phone is ageing.",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "Most people don't find out until it's too late.",
            style: TextStyle(fontSize: 18, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            "Techare helps you understand your device health before problems happen.",
            style: TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildWideButton("Get Started", _nextPage),
          TextButton(
            onPressed: () {},
            child: const Text("Already have an account? Sign in", style: TextStyle(color: Colors.deepPurple)),
          )
        ],
      ),
    );
  }

  Widget _buildWideButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}