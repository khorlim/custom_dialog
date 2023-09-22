import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TriangleArrowLeft extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    path
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TriangleArrowLeft oldDelegate) => false;
}


class TriangleArrowRight extends CustomPainter {
  TriangleArrowRight();

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..style = PaintingStyle.fill;

    // Draw the triangle itself
    paint.color = Colors.white;
    var trianglePath = Path();
    trianglePath.moveTo(0, 0);
    trianglePath.lineTo(size.width, size.height / 2);
    trianglePath.lineTo(0, size.height);
    trianglePath.close();
    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(TriangleArrowRight oldDelegate) => false;
}

class TriangleArrowTop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    path
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TriangleArrowTop oldDelegate) => false;
}

class TriangleArrowDown extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    path
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TriangleArrowDown oldDelegate) => false;
}
