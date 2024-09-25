import 'package:flutter/material.dart';

class ManualScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'This is the Manual Screen.',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
