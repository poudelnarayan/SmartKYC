import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelfieStartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Selfie Guidelines")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Icon(
              Icons.camera_front,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              "How to Take a Perfect Selfie",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.green, size: 40),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Ensure you are in a well-lit room with natural light.",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.face, color: Colors.orange, size: 40),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Keep your face centered and within the oval guide.",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.no_flash, color: Colors.red, size: 40),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Avoid using flash, instead use ambient lighting.",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => context.go('/selfie-capture'),
              icon: Icon(Icons.arrow_forward),
              label: Text("Proceed to Capture"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
