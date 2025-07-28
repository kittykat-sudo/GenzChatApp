import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(
        "Welcome to ChatDrop",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
      ),
    );
  }
}
