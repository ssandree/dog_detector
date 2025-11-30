// lib/features/realtime/presentation/realtime_stream_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../application/realtime_session_controller.dart';

class RealtimeStreamScreen extends HookConsumerWidget {
  const RealtimeStreamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(realtimeSessionControllerProvider);
    final controller = ref.read(realtimeSessionControllerProvider.notifier);

    final viewerId = "viewer_1";

    useEffect(() {
      controller.init(viewerDeviceId: viewerId);
      return null;
    }, const []);

    final renderer = sessionState.renderer;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (renderer != null)
            Positioned.fill(child: RTCVideoView(renderer))
          else
            const Center(child: CircularProgressIndicator()),

          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    controller.switchCamera(false, viewerId);
                  },
                ),
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    controller.reconnect(viewerId);
                  },
                ),
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    controller.switchCamera(true, viewerId);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
