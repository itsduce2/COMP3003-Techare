import 'package:flutter/material.dart';

class BatteryCyclesAnimation extends StatefulWidget {
  final VoidCallback onContinue;
  const BatteryCyclesAnimation({super.key, required this.onContinue});

  @override
  State<BatteryCyclesAnimation> createState() => _BatteryCyclesAnimationState();
}

class _BatteryCyclesAnimationState extends State<BatteryCyclesAnimation>
  with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;

  //variables for 
  double _charge = 100;
  double _cycle = 0.0;
  bool _isCharging = false;
  bool _isComplete = false;

  //initialise animation controller
  @override
  void initState() { 
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(seconds: 1), _runSequence);
  }

  //runs the animation sequence
  Future<void> _runSequence() async {

    //discharge 100% to 50% + cycle 0 to 0.5
    await _animateTo(chargeLvl: 50, batteryCycle: 0.5);
    await Future.delayed(const Duration(seconds: 1));

    //charge 50% to 75% + cycle remains
    setState(() => _isCharging = true);
    await _animateTo(chargeLvl: 75, batteryCycle: 0.5);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isCharging = false);

    //discharge 75% to 25% + cycle 0.5 to 1.0
    await _animateTo(chargeLvl: 25, batteryCycle: 1.0);
    await Future.delayed(const Duration(seconds: 1));

    //reset back to 100%
    setState(() => _isCharging = true);
    await _animateTo(chargeLvl: 100, batteryCycle: 1.0);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isCharging = false);
    setState(() => _isComplete = true);
  }

  Future<void> _restartAnimation() async {
    setState(() {
      _charge = 100.0;
      _cycle = 0.0;
      _isCharging = false;
      _isComplete = false;
    });
    _runSequence();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.blueGrey[50],
    body: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Understanding Battery Cycles",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "Watch how battery cycles accumulate as you use and charge your device.",
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(260, 130),
                    painter: BatteryPainter(charge: _charge / 100),
                  ),
                  Text(
                    "${_charge.toInt()}%",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  Positioned(
                    left:0,
                    child:  Opacity(opacity: _isCharging ? 1.0 : 0.0, 
                    child: const Icon(Icons.bolt, size: 48, color: Colors.deepPurple  ),
                    )
                  )
                ],
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            "Cycles: ${_cycle.toStringAsFixed(1)}",
            style: const TextStyle(fontSize: 24, color: Colors.black54),
          ),
          const SizedBox(height: 40),
          // Refresh button shows when complete, continue button always shows
          if (_isComplete)
            IconButton(
              icon: const Icon(Icons.refresh, size: 32, color: Colors.deepPurple),
              onPressed: _restartAnimation,
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: widget.onContinue,
              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  //runs when the animation is complete
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animateTo({
    required double chargeLvl,
    required double batteryCycle,
    int sec = 2,
  }) async {
    //set the animation duration
    _controller.duration = Duration(seconds: sec);

    final startCharge = _charge;
    final startCycle = _cycle;

    //animations for charge level and battery cycle count
    final chargeAnimation = Tween<double>(begin: startCharge, end: chargeLvl)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    final cycleAnimation = Tween<double>(begin: startCycle, end: batteryCycle)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    //read animation values on each frame and update the state
    chargeAnimation.addListener(() {
      setState(() {
        _charge = chargeAnimation.value;
        _cycle = cycleAnimation.value;
      });
    });

    //play the animation from the start and wait till finished
    await _controller.forward(from: 0);
    
    }

}

class BatteryPainter extends CustomPainter {
  final double charge;
  const BatteryPainter({required this.charge});

  @override
  void paint(Canvas canvas, Size size) {

    //battery outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
  }

  //repaint when charge percent changes
  @override
  bool shouldRepaint(covariant BatteryPainter old) =>
      old.charge != charge;
}