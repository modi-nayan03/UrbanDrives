import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextEditingController? controller; // Add optional controller

  const CustomTextField({
    super.key,
    required this.label,
    this.onSaved,
    this.validator,
    this.controller,
    required Null Function(dynamic value) onChanged, required bool enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        controller: controller, // Use the provided controller
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}

