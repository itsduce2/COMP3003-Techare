import 'package:flutter/material.dart';

const List<Map<String, dynamic>> _surveyQuestions = [
  {
    'question': 'What is the main issue you\'re experiencing?',
    'options': [
      'Battery draining quickly',
      'Device overheating',
      'Running out of storage',
      'Device running slowly',
      'Other',
    ],
  },
  {
    'question': 'How long has this been happening?',
    'options': [
      'Just started today',
      'A few days',
      'A week or more',
      'Always been an issue',
    ],
  },
  {
    'question': 'How severe is the issue?',
    'options': [
      'Minor (little impact on use)',
      'Moderate (affects daily use)',
      'Severe (device is barely usable)',
    ],
  },
];

class TroubleshootingSurveyDialog extends StatefulWidget {
  final void Function(String category) onComplete;

  const TroubleshootingSurveyDialog({super.key, required this.onComplete});

  @override
  State<TroubleshootingSurveyDialog> createState() => _TroubleshootingSurveyDialogState();
}

class _TroubleshootingSurveyDialogState extends State<TroubleshootingSurveyDialog> {

  int _step = 0;
  String? _selectedAnswer;
  String? _firstAnswer;

  String _mapToCategory(String answer) {
    final String lower = answer.toLowerCase();
    if (lower.contains('battery')) return 'Battery';
    if (lower.contains('overheating')) return 'Overheating';
    if (lower.contains('storage')) return 'Storage';
    return 'All';
  }

  void _next() {
    if (_selectedAnswer == null) return;
    if (_step == 0) _firstAnswer = _selectedAnswer;
    if (_step < _surveyQuestions.length - 1) {
      setState(() {
        _step++;
        _selectedAnswer = null;
      });
    } else {
      widget.onComplete(_mapToCategory(_firstAnswer ?? ''));
    }
  }

  void _back() {
    setState(() {
      _step--;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> question = _surveyQuestions[_step];
    final List<String> options = List<String>.from(question['options']);

    return AlertDialog(
      title: Text('Question ${_step + 1} of ${_surveyQuestions.length}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              question['question'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            //padding
            const SizedBox(height: 12),

            ...options.map(
              (option) => RadioListTile<String>(
                title: Text(option, style: const TextStyle(fontSize: 14)),
                value: option,
                groupValue: _selectedAnswer,
                activeColor: Colors.deepPurpleAccent,
                contentPadding: EdgeInsets.zero,
                dense: true,
                onChanged: (val) => setState(() => _selectedAnswer = val),
              ),
            ),

          ],
        ),
      ),
      actions: [

        if (_step > 0)
          TextButton(
            onPressed: _back,
            child: const Text('Back'),
          ),

        FilledButton(
          onPressed: _selectedAnswer == null ? null : _next,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
          ),
          child: Text(
            _step < _surveyQuestions.length - 1 ? 'Next' : 'See Results',
          ),
        ),

      ],
    );
  }
}
