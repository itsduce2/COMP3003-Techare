import 'package:flutter/material.dart';
import '../../data/tutorials.dart';

class TutorialPreviewDialog extends StatelessWidget {
  final Tutorial tutorial;
  final VoidCallback onStart;

  const TutorialPreviewDialog({
    super.key,
    required this.tutorial,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> tools = tutorial.tools;
    final String warning = tutorial.warning;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tutorial.title),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // tools section
            if (tools.isNotEmpty) ...[
              const Text(
                'Tools Required',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              //padding
              const SizedBox(height: 8),
              ...tools.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $t', style: const TextStyle(fontSize: 14)),
                ),
              ),
              //padding
              const SizedBox(height: 12),
              InkWell(
                onTap: () {},
                child: const Text(
                  'Buy spare parts',
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              //padding
              const SizedBox(height: 16),
            ],

            // warning section
            if (warning.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    //padding
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Warning',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          //padding
                          const SizedBox(height: 4),
                          Text(
                            warning,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: onStart,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
          ),
          child: const Text('Start Tutorial'),
        ),
      ],
    );
  }
}
