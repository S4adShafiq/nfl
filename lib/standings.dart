import 'package:flutter/material.dart';

class Live extends StatelessWidget {
  const Live({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SizedBox.shrink(), // Empty body
      ),
    );
  }
}
