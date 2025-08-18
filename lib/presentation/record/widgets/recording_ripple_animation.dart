import 'package:flutter/material.dart';

class MultiRippleAnimation extends StatefulWidget {
  final double size;
  final double amplitude;
  final Color color;
  final int rippleCount;

  const MultiRippleAnimation({
    super.key,
    required this.size,
    required this.amplitude,
    required this.color,
    this.rippleCount = 3,
  });

  @override
  State<MultiRippleAnimation> createState() => _MultiRippleAnimationState();
}

class _MultiRippleAnimationState extends State<MultiRippleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.amplitude < 0.01) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.center,
      children: List.generate(widget.rippleCount, (index) {
        final delay = index / widget.rippleCount;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double progress = (_controller.value + delay) % 1.0;
            double rippleSize =
                widget.size + 40 * widget.amplitude * progress; // 물결 확산
            double opacity = (1 - progress) * 0.3 * widget.amplitude; // 투명도 감소

            return Container(
              width: rippleSize,
              height: rippleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(opacity),
              ),
            );
          },
        );
      }),
    );
  }
}
