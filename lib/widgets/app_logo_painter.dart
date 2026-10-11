import 'package:flutter/material.dart';

class AppLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()..color = const Color(0xFF0D4B97);
    final path = Path();
    path.moveTo(size.width * 0.08, size.height * 0.18);
    path.lineTo(size.width * 0.72, size.height * 0.18);
    path.lineTo(size.width * 0.72, size.height * 0.32);
    path.lineTo(size.width * 0.36, size.height * 0.32);
    path.lineTo(size.width * 0.36, size.height * 0.52);
    path.lineTo(size.width * 0.68, size.height * 0.52);
    path.lineTo(size.width * 0.68, size.height * 0.66);
    path.lineTo(size.width * 0.36, size.height * 0.66);
    path.lineTo(size.width * 0.36, size.height * 0.82);
    path.lineTo(size.width * 0.08, size.height * 0.82);
    path.close();
    canvas.drawPath(path, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}