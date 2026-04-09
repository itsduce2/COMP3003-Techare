import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _habitController = TextEditingController();
  int _selectedYears = 0;
  int _selectedMonths = 0;

  void _nextPage() {
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Welcome Slide
          Center(child: ElevatedButton(onPressed: _nextPage, child: const Text("Get Started"))),
          
          // Age Slide
          _buildAgeSlide(),

          // Habit Slide
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Daily Charging Habits", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Average charge cycles per day:", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                TextField(
                  controller: _habitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "e.g. 1.2", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 40),
                ElevatedButton(onPressed: _nextPage, child: const Text("Finalize")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSlide() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("How old is your phone?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<int>(value: _selectedYears, items: List.generate(11, (i) => DropdownMenuItem(value: i, child: Text("$i Y"))), onChanged: (v) => setState(() => _selectedYears = v!)),
              DropdownButton<int>(value: _selectedMonths, items: List.generate(12, (i) => DropdownMenuItem(value: i, child: Text("$i M"))), onChanged: (v) => setState(() => _selectedMonths = v!)),
            ],
          ),
          ElevatedButton(onPressed: _nextPage, child: const Text("Continue")),
        ],
      ),
    );
  }
}