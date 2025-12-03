// lib/features/cam/camera_main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'application/cam_controller.dart';
import 'application/cam_state.dart';
import 'application/cam_runtime_engine.dart';

import '../devices/providers/device_bootstrap_provider.dart';
import '../devices/data/device_api_service.dart';
import '../pet/application/current_pet_provider.dart';

import 'widgets/cam_preview.dart';
import 'widgets/cam_status_bar.dart';
import 'widgets/cam_settings_panel.dart';

class CameraMainScreen extends HookConsumerWidget {
  const CameraMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      return () => SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
    }, []);

    final bootstrap = ref.watch(deviceBootstrapProvider);
    if (bootstrap.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (bootstrap.hasError) {
      return const Scaffold(
        body: Center(child: Text("기기 정보를 불러올 수 없습니다.")),
      );
    }

    final camState = ref.watch(camControllerProvider).value ??
        const CamState.initial();

    final runtime = ref.read(camRuntimeEngineProvider);
    final camId = ref.watch(currentDeviceIdProvider);
    final pet = ref.watch(currentPetProvider);
    final petId = pet?.petId?.toString();

    final camRunning = camState.cameraInitialized && camState.detecting;

    Future<void> _start() async {
      if (camId.isEmpty) return _show(context, "cameraId 없음");
      if (petId == null) return _show(context, "petId 없음");

      await runtime.start(
        cameraId: camId,
        petId: petId,
        deviceId: camId,
      );
    }

    Future<void> _stop() async {
      if (petId == null) return;
      await runtime.stop(
        petId: petId,
        deviceId: camId,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: CamPreview()),

            Positioned(
              right: 16,
              top: 16,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: CamSettingsPanel(),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 16,
              top: 16,
              child: CamStatusBar(
                camRunning: camRunning,
                sceneActive: camState.sceneActive,
                streamingConnected: false,
                streamingConnecting: false,
              ),
            ),

            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: camRunning ? Colors.red : Colors.green,
                  ),
                  onPressed: () => camRunning ? _stop() : _start(),
                  child: Text(
                    camRunning ? "CAM 종료" : "CAM 시작",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _show(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
