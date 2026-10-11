import 'package:firebase_task_manager/widgets/app_logo_painter.dart';
import 'package:flutter/material.dart';

class TaskManagerLogo extends StatelessWidget {
  const TaskManagerLogo({
    super.key,
    required this.size,
    this.showBadge = false,
  });

  final double size;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 16,
      height: size + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.28),
              border: Border.all(color: const Color(0xFFE2E5EA)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 12,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: CustomPaint(
                size: Size(size * 0.58, size * 0.58),
                painter: AppLogoPainter(),
              ),
            ),
          ),
          if (showBadge)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4A123),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
