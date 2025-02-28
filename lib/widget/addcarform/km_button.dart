import 'package:flutter/material.dart';

class KMButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;
  final String value; // Add value for proper use

  const KMButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSelected = false,
    required this.value, // Require a value
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          side: const BorderSide(color: Colors.grey),
        ),
        child: Text(label),
      ),
    );
  }
}

