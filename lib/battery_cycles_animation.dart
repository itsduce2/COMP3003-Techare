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


  //initialise animation controller
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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