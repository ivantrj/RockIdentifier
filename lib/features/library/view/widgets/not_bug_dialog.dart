import 'package:flutter/material.dart';

class NotBugDialog extends StatelessWidget {
  const NotBugDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDarkMode ? const Color(0xFF2A2A36) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'No Bug Found',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'This image doesn\'t appear to contain a bug. Please try taking a photo of a bug.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
