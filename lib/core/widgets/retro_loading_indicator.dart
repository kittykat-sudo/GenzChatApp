import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'dart:math';

/// A retro-styled loading indicator with four colored, pulsing dots.
class RetroLoadingIndicator extends StatefulWidget {
  final double size;

  const RetroLoadingIndicator({super.key, this.size = 80.0});

  @override
  State<RetroLoadingIndicator> createState() => _RetroLoadingIndicatorState();
}

class _RetroLoadingIndicatorState extends State<RetroLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
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
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RetroProgressPainter(animationValue: _controller.value),
        );
      },
    );
  }
}

class _RetroProgressPainter extends CustomPainter {
  final double animationValue;

  _RetroProgressPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;
    final dotRadius = size.width / 12;

    const colors = [
      AppColors.retroTeal,
      AppColors.retroOrange,
      AppColors.retroBlue,
      AppColors.accentPink, // Using accentPink instead of retroPink
    ];

    for (int i = 0; i < 4; i++) {
      final angle = (pi / 2) * i;
      final offset = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      // Determine which dot is currently "active"
      final activeDot = (animationValue * 4).floor() % 4;
      final paint =
          Paint()
            ..color = colors[i]
            // Make the active dot slightly larger and more opaque
            ..style = PaintingStyle.fill;

      if (i == activeDot) {
        canvas.drawCircle(offset, dotRadius * 1.2, paint);
      } else {
        canvas.drawCircle(
          offset,
          dotRadius,
          paint..color = colors[i].withOpacity(0.5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
