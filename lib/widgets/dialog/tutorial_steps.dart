import 'package:flutter/material.dart';
import '../../data/tutorials.dart';

class TutorialStepsDialog extends StatefulWidget {
  final Tutorial tutorial;

  const TutorialStepsDialog({super.key, required this.tutorial});

  @override
  State<TutorialStepsDialog> createState() => _TutorialStepsDialogState();
}

class _TutorialStepsDialogState extends State<TutorialStepsDialog> {

  int _currentStep = 0;

  List<TutorialStep> get _steps => widget.tutorial.steps;

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    final step = steps[_currentStep];
    final int total = steps.length;
    final bool isLast = _currentStep == total - 1;

    // check if this step has a local asset image
    final String? imageAsset = step.imageAsset;
    final bool hasImage = imageAsset != null && imageAsset.isNotEmpty;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${_currentStep + 1} of $total',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          //padding
          const SizedBox(height: 4),
          Text(
            widget.tutorial.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // shows local asset image if available, falls back to icon placeholder
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imageAsset,
                  height: 180,
                  width: 280,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.smartphone, size: 60, color: Colors.grey),
                ),
              ),

            //padding
            const SizedBox(height: 16),

            Text(
              step.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            //padding
            const SizedBox(height: 8),

            Text(
              step.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),

            //padding
            const SizedBox(height: 12),

            // wikihow attribution shown only on steps that have images
            if (hasImage)
              const Text(
                'Tutorial images © wikiHow (wikihow.com) · CC BY-NC-SA 3.0',
                style: TextStyle(fontSize: 10, color: Colors.black38),
                textAlign: TextAlign.center,
              ),

          ],
        ),
      ),
      actions: [

        // only show previous if not on first step
        if (_currentStep > 0)
          OutlinedButton(
            onPressed: () => setState(() => _currentStep--),
            child: const Text('Previous'),
          ),

        FilledButton(
          onPressed: () {
            if (!isLast) {
              setState(() => _currentStep++);
            } else {
              Navigator.pop(context);

              //tutorial complete snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.tutorial.title} tutorial complete!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
          ),
          child: Text(isLast ? 'Finish' : 'Next'),
        ),

      ],
    );
  }
}
