import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';

/// Retro-styled pulsing dots with arcade-style loading text
class RetroTypingDots extends StatefulWidget {
  final int dotCount;
  final double dotSize;
  final double spacing;
  final Duration duration;
  final String loadingText;
  // final bool showText;
  final TextStyle? textStyle;

  const RetroTypingDots({
    super.key,
    this.dotCount = 3,
    this.dotSize = 10,
    this.spacing = 8,
    this.duration = const Duration(milliseconds: 900),
    this.loadingText = '',
    // this.showText = false,
    this.textStyle,
  });

  @override
  State<RetroTypingDots> createState() => _RetroTypingDotsState();
}

class _RetroTypingDotsState extends State<RetroTypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Cycle through retro palette
  final List<Color> _palette = const [
    AppColors.retroTeal,
    AppColors.retroOrange,
    AppColors.retroBlue,
    AppColors.accentPink,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotValue(int index) {
    // Stagger each dot using an Interval window
    final start = (index / (widget.dotCount + 1)).clamp(0.0, 1.0);
    final end = (start + 0.6).clamp(0.0, 1.0); // window length
    final curved =
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ).value;
    // Make it "pulse" up then down
    return (curved <= 0.5) ? (curved * 2) : (1 - (curved - 0.5) * 2);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dots row
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.dotCount, (i) {
                final v = _dotValue(i);
                final color = _palette[i % _palette.length];
                final scale = 0.85 + (0.35 * v);
                final opacity = 0.4 + (0.6 * v);

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.dotSize,
                      height: widget.dotSize,
                      decoration: BoxDecoration(
                        color: color.withOpacity(opacity),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withOpacity(
                            0.2,
                          ), // subtle retro edge
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.border,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            // Loading text
            if (widget.loadingText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                widget.loadingText,
                style:
                    widget.textStyle ??
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      decoration: TextDecoration.none,
                      fontFamily: 'ZillaSlab',
                      color: AppColors.retroTeal.withOpacity(0.8),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(1, 1),
                          blurRadius: 0,
                        ),
                      ],
                    ),
              ),
            ],
          ],
        );
      },
    );
  }
}
