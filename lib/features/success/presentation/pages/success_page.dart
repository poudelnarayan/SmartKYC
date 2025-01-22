import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Success")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Verification Successful!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/user-profile');
              },
              child: Text("Go to Your Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
