import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A circular gauge widget for displaying similarity scores
class SimilarityGauge extends StatefulWidget {
  final double score;
  final double size;
  final double strokeWidth;
  final Color? color;
  final bool showPercentage;
  final String? label;

  const SimilarityGauge({
    super.key,
    required this.score,
    this.size = 120.0,
    this.strokeWidth = 8.0,
    this.color,
    this.showPercentage = true,
    this.label,
  });

  @override
  State<SimilarityGauge> createState() => _SimilarityGaugeState();
}

class _SimilarityGaugeState extends State<SimilarityGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.score).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(SimilarityGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(begin: _animation.value, end: widget.score)
          .animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            ),
          );
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _GaugePainter(
            progress: _animation.value,
            strokeWidth: widget.strokeWidth,
            color: widget.color ?? _getScoreColor(_animation.value),
            showPercentage: widget.showPercentage,
            label: widget.label,
          ),
        );
      },
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final bool showPercentage;
  final String? label;

  _GaugePainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.showPercentage,
    this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (progress / 100) * 2 * math.pi;
    const startAngle = -math.pi / 2; // Start from top

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw percentage text
    if (showPercentage) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${progress.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: size.width * 0.2,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
    }

    // Draw label if provided
    if (label != null) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: label!,
          style: TextStyle(
            fontSize: size.width * 0.12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(
          center.dx - labelPainter.width / 2,
          center.dy + size.width * 0.15,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _GaugePainter &&
        (oldDelegate.progress != progress ||
            oldDelegate.color != color ||
            oldDelegate.label != label);
  }
}
