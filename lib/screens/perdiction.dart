import 'package:flutter/material.dart';
import '../services/battery_prediction_service.dart';
import '../widgets/animations/battery_cycles_animation.dart';

class Prediction extends StatefulWidget {
  final BatteryPredictionResult result;
  const Prediction({super.key, required this.result});

  @override
  State<Prediction> createState() => _PredictionState();
}

class _PredictionState extends State<Prediction> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  //next page
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  //prev page
  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    //if there isn't enough data, show screen
    if (!widget.result.canPredict) {
      return _noCycleData();
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _currentHealthSlide(),
            _futureProjectionsSlide(),
            _recommendationSlide(),
          ],
        ),
      ),
    );
  }

  //not enough data screen 
  Widget _noCycleData() {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //info icon
              const Icon(Icons.info_outline, size: 80, color: Colors.deepPurple),

              //padding
              const SizedBox(height: 24),

              //title
              const Text(
                'Not enough data yet',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              //padding
              const SizedBox(height: 16),

              //explanation message
              Text(
                widget.result.insufficientDataMessage,
                style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.6),
                textAlign: TextAlign.center,
              ),

              //padding
              const SizedBox(height: 40),

              //dismiss button
              _continueBtn('Got it', () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  //Current health slide 
  Widget _currentHealthSlide() {
    final capacity = widget.result.currentExpectedCapacity;

    Color healthColor;
    String healthLabel;
    IconData healthIcon;

    // colour and label based on batterty capacity 
    if (capacity >= 85) {
      healthColor = Colors.green;
      healthLabel = 'Good';
      healthIcon = Icons.check_circle_outline;
    } else if (capacity >= 75) {
      healthColor = Colors.orange;
      healthLabel = 'Fair';
      healthIcon = Icons.warning_amber_outlined;
    } else {
      healthColor = Colors.red;
      healthLabel = 'Poor';
      healthIcon = Icons.error_outline;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          //close button top right
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),

          Icon(healthIcon, size: 80, color: healthColor),

          //padding
          const SizedBox(height: 24),

          //title
          const Text(
            'Current Battery Health',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          //padding
          const SizedBox(height: 16),

          //large capacity num
          Text(
            '${capacity.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: healthColor),
          ),
          const Text(
            'of original capacity remaining',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),

          //padding
          const SizedBox(height: 24),

          //health status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: healthColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              healthLabel,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: healthColor),
            ),
          ),

          //padding
          const SizedBox(height: 16),

          //cycle count and confidence label
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black38),
              children: [
                TextSpan(text: 'Based on ~${widget.result.estimatedCycles} estimated charge cycles\n'),
                TextSpan(
                  text: 'Confidence: ${widget.result.confidenceLabel}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: switch (widget.result.confidenceLabel) {
                      'High'   => Colors.green,
                      'Medium' => Colors.orange,
                      _        => Colors.red,
                    },
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          //padding
          const SizedBox(height: 8),

          //performance msg
          const Text(
            'Batteries below 80% may noticeably affect performance and battery life.',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const Spacer(),

          //page indicator
          _pageIndicator(0),

          //padding
          const SizedBox(height: 16),

          //next button
          _continueBtn('Next', _nextPage),
        ],
      ),
    );
  }

  //future projections (slid 2)
  Widget _futureProjectionsSlide() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          //back button
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: _prevPage,
            ),
          ),
          const Spacer(),

          const Icon(Icons.trending_down, size: 80, color: Colors.black),

          //padding
          const SizedBox(height: 24),

          //title
          const Text(
            'Future Projections',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          //padding
          const SizedBox(height: 8),

          //description
          const Text(
            'Here\'s how your battery is expected to age over the next year.',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            textAlign: TextAlign.center,
          ),

          //padding
          const SizedBox(height: 32),

          //projection cards for now, 6 months, 12 months
          _projectionCard('Now', widget.result.currentExpectedCapacity),
          const SizedBox(height: 16),
          _projectionCard('In 6 months', widget.result.predicted6Months),
          const SizedBox(height: 16),
          _projectionCard('In 12 months', widget.result.predicted12Months),
          const Spacer(),

          //page indicator
          _pageIndicator(1),

          //padding
          const SizedBox(height: 16),

          //next button
          _continueBtn('Next', _nextPage),
        ],
      ),
    );
  }

  //recommendation (slide 3)
  Widget _recommendationSlide() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          //back button
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: _prevPage,
            ),
          ),
          const Spacer(),

          const Icon(Icons.lightbulb_outline, size: 80, color: Colors.orange),

          //padding
          const SizedBox(height: 24),

          //title
          const Text(
            'Recommendation',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          //padding
          const SizedBox(height: 16),

          //recommendation text
          Text(
            widget.result.recommendation,
            style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
            textAlign: TextAlign.center,
          ),

          //padding
          const SizedBox(height: 32),

          //learn about charge cycles (animation and return)
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BatteryCyclesAnimation(
                    onContinue: () => Navigator.pop(context),
                  ),
                ),
              );
            },
            label: const Text(
              'Learn about charge cycles',
              style: TextStyle(color: Colors.deepPurple),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.deepPurple),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),

          //padding
          const SizedBox(height: 32),

          //disclaimer
          const Text(
            '*Estimates based on the NASA Li-ion Battery Aging Dataset and your device settings. Actual results may vary.',
            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const Spacer(),

          //page indicator
          _pageIndicator(2),

          //padding
          const SizedBox(height: 16),

          //done button
          _continueBtn('Done', () => Navigator.pop(context)),
        ],
      ),
    );
  }

  //projection card and progress bar
  Widget _projectionCard(String label, double value) {
    Color colour = Colors.green;
    if (value < 80) colour = Colors.red;
    else if (value < 85) colour = Colors.orange;

    //box container
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //time label
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),

                //padding
                const SizedBox(height: 8),

                //capacity progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(colour),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          //capacity percentage
          Text(
            '${value.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colour),
          ),
        ],
      ),
    );
  }

  //page indicator dots
  Widget _pageIndicator(int activeIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = index == activeIndex;
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

  //full width button
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
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
