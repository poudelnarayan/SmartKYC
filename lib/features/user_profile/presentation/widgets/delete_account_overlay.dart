import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class DeleteAccountOverlay extends StatefulWidget {
  const DeleteAccountOverlay({super.key});

  @override
  State<DeleteAccountOverlay> createState() => _DeleteAccountOverlayState();
}

class _DeleteAccountOverlayState extends State<DeleteAccountOverlay> {
  @override
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Lottie.network(
                'https://lottie.host/2c924e47-a1e2-48de-8c11-5c3ac51dd60f/MYBOcxdpmY.json',
                fit: BoxFit.contain,
                repeat: false,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.delete_forever_outlined,
                    size: 80,
                    color: Colors.white,
                  );
                },
              ),
            ).animate().scale(),
            const SizedBox(height: 32),
            Text(
              'Deleting Account',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn().slideY(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              child: Text(
                'Deleting your account and all associated data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ).animate().fadeIn().slideY(),
          ],
        ),
      ),
    );
  }
}
