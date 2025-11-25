// lib/features/cam/camera_main_screen.dart

import 'package:flutter/material.dart';

class CameraMainScreen extends StatelessWidget {
  const CameraMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Camera Mode (임시 화면)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
