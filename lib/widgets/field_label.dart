import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF6D7380),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}
