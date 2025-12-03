// lib/features/cam/widgets/cam_start_button.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../application/cam_runtime_engine.dart';
import '../../pet/application/current_pet_provider.dart';
import '../../devices/data/device_api_service.dart';

class CamStartButton extends ConsumerWidget {
  final bool running;

  const CamStartButton({super.key, required this.running});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.read(camRuntimeEngineProvider);

    void showMsg(String msg) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }

    return GestureDetector(
      onTap: () async {
        if (running) {
          final pet = ref.read(currentPetProvider);
          final petId = pet?.petId?.toString();
          final camId = ref.read(currentDeviceIdProvider);

          if (petId != null && camId.isNotEmpty) {
            await runtime.stop(
              petId: petId,
              deviceId: camId,
            );
          }

          return;
        }

        final camId = ref.read(currentDeviceIdProvider);
        final pet = ref.read(currentPetProvider);
        final petId = pet?.petId?.toString();

        if (camId.isEmpty) {
          showMsg("cameraId 없음");
          return;
        }
        if (petId == null) {
          showMsg("petId 없음");
          return;
        }

        await runtime.start(
          cameraId: camId,
          petId: petId,
          deviceId: camId,
        );
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
