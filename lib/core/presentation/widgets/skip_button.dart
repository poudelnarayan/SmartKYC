import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SkipButton extends StatelessWidget {
  final VoidCallback onSkip;
  final Color? backgroundColor;
  final Color? textColor;

  const SkipButton({
    super.key,
    required this.onSkip,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: InkWell(
          onTap: onSkip,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: backgroundColor ??
                  const Color.fromARGB(255, 185, 181, 181).withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (textColor ?? const Color.fromARGB(255, 151, 147, 147))
                    .withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: textColor ?? Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}
