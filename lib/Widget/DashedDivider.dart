
import 'dart:ui';

import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashGap;

  DashedDivider({
    this.height = 1.0,
    this.color = Colors.grey,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromHeight(height),
      painter: DashedLinePainter(
        color: color,
        dashWidth: dashWidth,
        dashGap: dashGap,
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashGap;

  DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..style = PaintingStyle.stroke;

    double startX = 0.0;
    double endX = size.width;
    double currentX = startX;

    while (currentX < endX) {
      canvas.drawLine(
        Offset(currentX, size.height / 2),
        Offset(
          currentX + dashWidth,
          size.height / 2,
        ),
        paint,
      );
      currentX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}