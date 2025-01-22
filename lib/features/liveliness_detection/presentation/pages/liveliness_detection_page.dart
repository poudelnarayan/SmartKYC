import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LivelinessDetectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Liveliness Detection")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.go('/success');
              },
              child: Text("Start Liveliness Detection"),
            ),
          ],
        ),
      ),
    );
  }
}
