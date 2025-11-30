// lib/features/cam/camera_main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'application/cam_controller.dart';
import 'application/cam_engine.dart';
import '../devices/data/device_api_service.dart';
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
      return () {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      };
    }, const []);

    final camState = ref.watch(camControllerProvider).value ?? const CamState.initial();
    final streamState = ref.watch(camEngineProvider).value ?? CamStreamingState.initial;

    final camController = ref.read(camControllerProvider.notifier);
    final camEngine = ref.read(camEngineProvider.notifier);

    final camDeviceId = ref.watch(currentDeviceIdProvider);
    final viewerDeviceId = ref.watch(currentViewerIdProvider);

    Future<void> start() async {
      await camController.startCam();
      camEngine.setDeviceIds(camDeviceId, viewerDeviceId);
      await camEngine.startStreaming();
    }

    Future<void> stop() async {
      await camEngine.stopStreaming();
      await camController.stopCam();
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
                camRunning: camState.isRunning,
                sceneActive: camState.sceneActive,
                streamingConnected: streamState.connected,
                streamingConnecting: streamState.connecting,
              ),
            ),

            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: camState.isRunning ? Colors.red : Colors.green),
                  onPressed: () async {
                    if (!camState.isRunning) {
                      await start();
                    } else {
                      await stop();
                    }
                  },
                  child: Text(
                    camState.isRunning ? "CAM 종료" : "CAM 시작",
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
}
