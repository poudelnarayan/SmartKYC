import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const NavigationButtons({
    super.key,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: onPrev,
          child: const Text("Prev"),
        ),
        ElevatedButton(
          onPressed: onNext,
          child: const Text("Next"),
        ),
      ],
    );
  }
}
