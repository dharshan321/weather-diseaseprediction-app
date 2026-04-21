import 'dart:math';
import 'package:flutter/material.dart';
import '../services/risk_service.dart';

class RiskMeter extends StatelessWidget {
  final int score;
  final RiskLevel level;

  const RiskMeter({
    super.key,
    required this.score,
    required this.level,
  });

  Color get _levelColor {
    switch (level) {
      case RiskLevel.LOW:
        return Colors.green;
      case RiskLevel.MODERATE:
        return Colors.orange;
      case RiskLevel.HIGH:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: CustomPaint(
                painter: _RiskPainter(
                  score: score,
                  color: _levelColor,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: _levelColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  level.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _levelColor,
                        letterSpacing: 2,
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _RiskPainter extends CustomPainter {
  final int score;
  final Color color;

  _RiskPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 15.0;

    // Background track
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5,
      false,
      bgPaint,
    );

    // Active track
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (pi * 1.5) * (score / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
