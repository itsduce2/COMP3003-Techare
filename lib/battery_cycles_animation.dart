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