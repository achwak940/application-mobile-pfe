import 'package:flutter/material.dart';

class SuccessDialog extends StatefulWidget {
  final VoidCallback onContinue;
  
  const SuccessDialog({super.key, required this.onContinue});

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 60),
          SizedBox(height: 10),
          Text('Welcome!'),
        ],
      ),
      content: const Text(
        'You have successfully logged in.',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onContinue();
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}