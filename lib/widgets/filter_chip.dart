import 'package:flutter/material.dart';

class FiltersChip extends StatelessWidget {
  const FiltersChip({
    super.key,
    required this.label,
    required this.selected,
    required this.count,
  });

  final String label;
  final bool selected;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1D2433) : const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 15),
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF1D2433),
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' $count',
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF6C7585),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
