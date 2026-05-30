import 'dart:math';
import 'package:flutter/material.dart';

class AnalogClockWidget extends StatefulWidget {
  final DateTime? time;
  final double size;
  final Color faceColor;
  final Color handColor;
  final Color accentColor;

  const AnalogClockWidget({
    super.key,
    this.time,
    this.size = 220,
    this.faceColor = Colors.white,
    this.handColor = Colors.black87,
    this.accentColor = Colors.deepOrange,
  });

  @override
  State<AnalogClockWidget> createState() => _AnalogClockWidgetState();
}

class _AnalogClockWidgetState extends State<AnalogClockWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _ClockPainter(
            time: widget.time ?? DateTime.now(),
            faceColor: widget.faceColor,
            handColor: widget.handColor,
            accentColor: widget.accentColor,
          ),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final DateTime time;
  final Color faceColor;
  final Color handColor;
  final Color accentColor;

  const _ClockPainter({
    required this.time,
    required this.faceColor,
    required this.handColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, Paint()..color = faceColor);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = handColor.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final tickPaint = Paint()
      ..color = handColor.withOpacity(0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * pi / 180;
      final isHour = i % 5 == 0;
      final outer = radius * 0.92;
      final inner = isHour ? radius * 0.78 : radius * 0.87;
      tickPaint.strokeWidth = isHour ? 3 : 1.5;

      canvas.drawLine(
        Offset(center.dx + inner * cos(angle - pi / 2),
            center.dy + inner * sin(angle - pi / 2)),
        Offset(center.dx + outer * cos(angle - pi / 2),
            center.dy + outer * sin(angle - pi / 2)),
        tickPaint,
      );
    }

    final hourAngle =
        ((time.hour % 12) + time.minute / 60) / 12 * 2 * pi - pi / 2;
    _drawHand(canvas, center, radius * 0.55, hourAngle, 6, handColor);

    final minuteAngle =
        (time.minute + time.second / 60) / 60 * 2 * pi - pi / 2;
    _drawHand(canvas, center, radius * 0.75, minuteAngle, 4, handColor);

    final secondAngle = time.second / 60 * 2 * pi - pi / 2;
    _drawHand(canvas, center, radius * 0.82, secondAngle, 2, accentColor);

    canvas.drawCircle(center, 7, Paint()..color = accentColor);
    canvas.drawCircle(center, 4, Paint()..color = faceColor);
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double length,
    double angle,
    double width,
    Color color,
  ) {
    canvas.drawLine(
      center,
      Offset(center.dx + length * cos(angle), center.dy + length * sin(angle)),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ClockPainter old) =>
      old.time.second != time.second || old.faceColor != faceColor;
}