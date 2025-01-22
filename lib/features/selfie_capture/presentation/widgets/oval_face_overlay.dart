import 'package:flutter/material.dart';

class OvalFaceOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 310,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 4),
          borderRadius: BorderRadius.circular(200),
          color: Colors.transparent,
        ),
      ),
    );
  }
}
