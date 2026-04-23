import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techare_application_comp3003/widgets/animations/battery_cycles_animation.dart';
import 'login.dart';
import '../services/login_service.dart';
import '../navigation/navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // onboarding variables
  int _selYears = 0;
  int _selMonths = 0;
  double _phoneCycles = 0.5;
  String _selBrand = 'Other';
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // available brands for the brand picker
  final List<String> _brands = ['Apple', 'Samsung', 'Google', 'Other'];

  // Feature slides
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

  //next page with animation
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

// Save collected data and finish onboarding
Future<void> _completeOnboarding() async {
  // basic validation
  if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all fields.')),
    );
    return;
  }

  // register the new account
  final success = await LoginService.register(
    email: _email.text.trim().toLowerCase(),
    password: _password.text.trim(),
    name: _name.text.trim(),
  );

  if (!success) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An account with this email already exists.')),
    );
    return;
  }

  // save device profile values under the new user's namespace
  final email      = _email.text.trim().toLowerCase();
  final prefs      = await SharedPreferences.getInstance();
  await prefs.setString(LoginService.keyFor(email, 'phone_age'), '${_selYears}y ${_selMonths}m');
  await prefs.setString(LoginService.keyFor(email, 'phone_age_set_date'), DateTime.now().toIso8601String());
  await prefs.setString(LoginService.keyFor(email, 'charging_habit'), _phoneCycles.toStringAsFixed(1));
  await prefs.setString(LoginService.keyFor(email, 'phone_brand'), _selBrand);

  if (!mounted) return;

  // navigate to the main app
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const BottomNavigation()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background colour
      backgroundColor: Colors.blueGrey[50],
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), //user can only navigate with buttons
        onPageChanged: (int page) => setState(() => _currentPage = page),
        children: [
          _welcomeScreen(),
          ..._features.map((f) => _featSlides(f)).toList(),
          _phoneAgeScreen(),
          _brandScreen(),
          BatteryCyclesAnimation(onContinue: _nextPage),
          _cyclesScreen(),
          _signUpScreen(),
          _privacyScreen(),
        ],
      ),
    );
  }

  // Welcome screen
  Widget _welcomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0), // Padding
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
          _continueBtn("Get Started", _nextPage),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }, // Handle Sign In
            child: const Text("Already have an account? Sign in", style: TextStyle(color: Colors.deepPurple)),
          )
        ],
      ),
    );
  }

  // Feature slide
  Widget _featSlides(Map<String, dynamic> feature) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: _prevPage,
              ),
            ),
            Icon(feature['icon'], size: 80, color: Colors.deepPurple),
            const SizedBox(height: 32),
            Text(
              feature['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              feature['subtitle'],
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _slideIndicator(),
            const SizedBox(height: 32),
            _continueBtn("Continue", _nextPage),
          ],
        ),
      ),
    );
  }

  // Phone age screen
  Widget _phoneAgeScreen() {
    return _onboardingWrapper(
      title: "How old is your phone?",
      subtitle: "This helps us estimate your battery health",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dropdown("Years", _selYears, 11, (v) => setState(() => _selYears = v!)),
          const SizedBox(width: 20),
          _dropdown("Months", _selMonths, 12, (v) => setState(() => _selMonths = v!)),
        ],
      ),
      onContinue: _nextPage,
    );
  }

  // Brand picker screen - used to apply the correct degradation profile
  Widget _brandScreen() {
    return _onboardingWrapper(
      title: "What brand is your phone?",
      subtitle: "This lets us apply the correct battery degradation profile for your device.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Brand", style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selBrand,
            isExpanded: true,
            items: _brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: (v) => setState(() => _selBrand = v!),
          ),
        ],
      ),
      onContinue: _nextPage,
    );
  }

  // Charging habits screen
  Widget _cyclesScreen() {
    return _onboardingWrapper(
      title: "How do you typically charge your phone?",
      subtitle: "One charge cycle = 100% total battery used, even if topped up in smaller amounts.",
      child: Column(
        children: [
          Text(
            "${_phoneCycles.toStringAsFixed(1)} cycles per day",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          Slider(
            value: _phoneCycles,
            min: 0.5,
            max: 5.0,
            divisions: 9,
            activeColor: Colors.deepPurple,
            onChanged: (v) => setState(() => _phoneCycles = double.parse(v.toStringAsFixed(1))),
          ),
        ],
      ),
      onContinue: _nextPage,
    );
  }

  // Sign up screen
  Widget _signUpScreen() {
    return _onboardingWrapper(
      title: "Create your account",
      subtitle: "Join Techare to increase your device's lifetime",
      child: Column(
        children: [
          _textFieldInput(_name, "Name", Icons.person_outline),
          const SizedBox(height: 16),
          _textFieldInput(_email, "Email", Icons.email_outlined),
          const SizedBox(height: 16),
          _textFieldInput(_password, "Password", Icons.lock_outline, obscure: true),
        ],
      ),
      onContinue: _nextPage,
      buttonText: "Continue",
      additionalChildren: [
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }, // Handle Sign In
            child: const Text("Already have an account? Sign in", style: TextStyle(color: Colors.deepPurple)),
          ),
        )
      ],
    );
  }

  // Privacy notice screen
  Widget _privacyScreen() {
    return _onboardingWrapper(
      title: 'Your privacy matters',
      subtitle: 'Before you continue, here\'s how Techare handles your data.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PrivacyScreen(
            icon: Icons.smartphone_outlined,
            title: 'Device data stays on your device',
            body: 'Battery level, temperature, and storage readings are used only for diagnostics and are never uploaded.',
          ),
          const SizedBox(height: 20),
          _PrivacyScreen(
            icon: Icons.person_outline,
            title: 'Your account is stored locally',
            body: 'Your name, email, and password are saved only on this device using encrypted local storage.',
          ),
          const SizedBox(height: 20),
          _PrivacyScreen(
            icon: Icons.analytics_outlined,
            title: 'Prediction data',
            body: 'Battery predictions are calculated locally using your phone age and charging habits. No data is sent to external servers.',
          ),
        ],
      ),
      onContinue: _completeOnboarding,
      buttonText: 'Agree & Create Account',
    );
  }

  // Reusable component
  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Shared form wrapper for data screens
  Widget _onboardingWrapper({required String title, required String subtitle, required Widget child, required VoidCallback onContinue, String buttonText = "Continue", List<Widget>? additionalChildren}) {
    return Padding(
      padding: const EdgeInsets.all(24.0), // Padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: _prevPage,
          ),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 40),
          child,
          const SizedBox(height: 40),
          _continueBtn(buttonText, onContinue),
          if (additionalChildren != null) ...additionalChildren,
        ],
      ),
    );
  }

  // Full-width button
  Widget _continueBtn(String text, VoidCallback onPressed) {
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

  // Page indicator dots
  Widget _slideIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = (_currentPage - 1) == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.deepPurple : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // Years/Months dropdown
  Widget _dropdown(String label, int value, int count, ValueChanged<int?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        DropdownButton<int>(
          value: value,
          items: List.generate(count, (i) => i).map((v) => DropdownMenuItem(value: v, child: Text("$v"))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Text input field with icon
  Widget _textFieldInput(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _PrivacyScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _PrivacyScreen({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: Colors.deepPurple),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(body, style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}