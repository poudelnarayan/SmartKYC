import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MovementIndicator extends StatelessWidget {
  final String direction;
  final IconData icon;
  final bool completed;
  final bool active;

  const MovementIndicator({
    super.key,
    required this.direction,
    required this.icon,
    required this.completed,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = completed
        ? Colors.green
        : active
            ? Colors.white
            : Colors.white.withOpacity(0.3);

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed
            ? Colors.green.withOpacity(0.2)
            : active
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
        border: Border.all(
          color: baseColor,
          width: 2,
        ),
        boxShadow: completed || active
            ? [
                BoxShadow(
                  color: baseColor.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Icon(
        completed ? Icons.check_rounded : icon,
        color: baseColor,
        size: 36,
      ),
    ).animate(target: active && !completed ? 1 : 0).custom(
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1 + (value * 0.2),
              child: child,
            );
          },
        );
  }
}