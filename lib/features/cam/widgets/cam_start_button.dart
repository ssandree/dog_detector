// lib/features/cam/widgets/cam_start_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/cam_controller.dart';

class CamStartButton extends ConsumerWidget {
  final bool running;

  const CamStartButton({super.key, required this.running});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(camControllerProvider.notifier);

    return GestureDetector(
      onTap: () async {
        if (running) {
          await controller.stopCam();
        } else {
          await controller.startCam();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          color: running ? Colors.red : Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          running ? "종료하기" : "시작하기",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
